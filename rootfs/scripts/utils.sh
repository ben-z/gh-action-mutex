# Set up the mutex repo
# args:
#   $1: server_url
#   $2: repo_path
#   $3: repo_token
set_up_repo() {
	__server_url=$1
	__repo_path=$2
	__repo_token=$3

	git init --quiet
	git config --local user.name "github-bot" --quiet
	git config --local user.email "github-bot@users.noreply.github.com" --quiet
	#set +x
	#__b64str=$(echo "x-access-token:$__repo_token" | base64)
	#echo "::add-mask::$__b64str"
	#set -x
	#git config --local "http.$__server_url/.extraheader" "AUTHORIZATION: basic ${__b64str}"
	#git remote add origin "$__server_url/$__repo_path"
	git remote add origin "https://x-access-token:$__repo_token@github.com/$__repo_path"
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

