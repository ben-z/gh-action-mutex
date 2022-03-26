# Set up the mutex repo
# args:
#   $1: repo_url
set_up_repo() {
	__repo_url=$1

	git init --quiet
	git config --local user.name "github-bot" --quiet
	git config --local user.email "github-bot@users.noreply.github.com" --quiet
	git remote remove origin 2>/dev/null || true
	git remote add origin "$__repo_url"
}

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

	echo "[$__ticket_id] Enqueuing to branch $__branch, file $__queue_file"

	update_branch $__branch

	touch $__queue_file

	# if we are not in the queue, add ourself to the queue
	if [ -z "$(cat $__mutex_queue_file | grep -F $__ticket_id)" ]; then
		echo "$__ticket_id" >> "$__mutex_queue_file"

		git add $__queue_file
		git commit -m "[$__ticket_id] Enqueue " --quiet

		set +e # allow errors
		git push --set-upstream origin $__branch --quiet
		__has_error=$((__has_error + $?))
		set -e
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

	echo "[$__ticket_id] Waiting for lock"

	update_branch $__branch

	# if we are not the first in line, spin
	if [ "$(cat $__mutex_queue_file | head -n 1)" != "$__ticket_id" ]; then
		sleep 5
		wait_for_lock $@
	fi
}

# Wait for the lock to become available
# args:
#   $1: branch
#   $2: queue_file
#   $3: ticket_id
unlock() {
	__branch=$1
	__queue_file=$2
	__ticket_id=$3

	__has_error=0


	echo "[$__ticket_id] Unlocking"

	update_branch $__branch

	if [ "$(cat $__mutex_queue_file | head -n 1)" != "$__ticket_id" ]; then
		1>&2 echo "We don't have the lock! Ticket ID: $__ticket_id. Mutex file:"
		cat $__mutex_queue_file
		exit 1
	fi

	cat $__mutex_queue_file | tail -n +2 > ${__mutex_queue_file}.new
	mv ${__mutex_queue_file}.new $__mutex_queue_file

	git add $__queue_file
	git commit -m "[$__ticket_id] Unlock" --quiet

	set +e # allow errors
	git push --set-upstream origin $__branch --quiet
	__has_error=$((__has_error + $?))
	set -e

	if [ ! $__has_error -eq 0 ]; then
		sleep 1
		unlock $@
	fi
}

