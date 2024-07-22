#!/bin/bash -e

if [ $ARG_DEBUG != "false" ]; then
	set -x
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source "$SCRIPT_DIR/utils.sh"

mkdir -p "$ARG_CHECKOUT_LOCATION"
cd "$ARG_CHECKOUT_LOCATION"

__mutex_queue_file=mutex_queue
__repo_url="https://x-access-token:$ARG_REPO_TOKEN@$ARG_GITHUB_SERVER/$ARG_REPOSITORY"
cat "$GITHUB_WORKSPACE/.$GITHUB_RUN_ID"
export $(grep -v '^#' $GITHUB_WORKSPACE/.$GITHUB_RUN_ID | xargs -0)
__ticket_id=$ticket_id

set_up_repo "$__repo_url"
dequeue $ARG_BRANCH $__mutex_queue_file $__ticket_id

rm -f "$GITHUB_WORKSPACE/.$GITHUB_RUN_ID"
echo "Successfully unlocked"
