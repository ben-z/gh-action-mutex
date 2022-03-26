#!/bin/bash -e

# Update the branch to the latest from the remote. Or checkout to an orphan branch
# args:
#   $1: branch
update_branch() {
	__branch=$1

	# exit on error
	git switch --orphan gh-action-mutex/temp-branch-$(date +%s) --quiet
	git branch -D $__branch --quiet 2>/dev/null || true
	git fetch origin $__branch --quiet
	git checkout $__branch --quiet || git switch --orphan $__branch --quiet
}

# Add to the queue
# args:
#   $1: branch
#   $2: queue_file
#   $3: ticket_id
enqueue() {
	__branch=$1
	__queue_file=$2
	__ticket_id=$3

	__has_error=0

	echo "Enqueuing to branch $__branch, file $__queue_file, id $__ticket_id"

	update_branch $__branch
	__has_error=$((__has_error + $?))

	touch $__queue_file

	# if we are not in the queue, add ourself to the queue
	if [ $__has_error -eq 0 ] && [ -z "$(cat $__mutex_queue_file | grep -F $__ticket_id)" ]; then
		echo "$__ticket_id" >> "$__mutex_queue_file"

		git add $__queue_file
		git commit -m "Enqueuing $__ticket_id" --quiet
		__has_error=$((__has_error + $?))

		git push --set-upstream origin $__branch --quiet
		__has_error=$((__has_error + $?))
	fi

	if [ ! $__has_error -eq 0 ]; then
		sleep 1
		enqueue $@
	fi
}

# Wait for the lock to become available
# args:
#   $1: branch
#   $2: queue_file
#   $3: ticket_id
wait_for_lock() {
	__branch=$1
	__queue_file=$2
	__ticket_id=$3

	__has_error=0

	echo "Waiting for lock for ticket $__ticket_id"

	update_branch $__branch

	# if we are not the first in line, spin
	if [ "$(cat $__mutex_queue_file | head -n 1)" != "$__ticket_id" ]; then
		sleep 5
		wait_for_lock $@
	fi
}

echo "Cloning and checking out $ARG_REPOSITORY:$ARG_BRANCH in $ARG_CHECKOUT_LOCATION"

mkdir -p "$ARG_CHECKOUT_LOCATION"
cd "$ARG_CHECKOUT_LOCATION"
pwd

__mutex_queue_file=mutex_queue
__server_url=https://$GITHUB_TOKEN@github.com

git init --quiet
git config --local user.name "github-bot" --quiet
git config --local user.email "github-bot@users.noreply.github.com" --quiet
git remote add origin "$__server_url/$ARG_REPOSITORY"

__ticket_id="$GITHUB_RUN_ID-$(date +%s)"
echo "::save-state name=ticket_id::$__ticket_id"

enqueue $ARG_BRANCH $__mutex_queue_file $__ticket_id

echo "Queue file:"
cat $__mutex_queue_file

wait_for_lock $ARG_BRANCH $__mutex_queue_file $__ticket_id

# We have the lock now

ls -alh
uname -a

time=$(date)
echo "::set-output name=time::$time"

