#!/bin/bash

# TODO: remove
echo "Hello $1"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source "$SCRIPT_DIR/utils.sh"

echo "Cloning and checking out $ARG_REPOSITORY:$ARG_BRANCH in $ARG_CHECKOUT_LOCATION"

mkdir -p "$ARG_CHECKOUT_LOCATION"
cd "$ARG_CHECKOUT_LOCATION"

__mutex_queue_file=mutex_queue
__server_url=https://$GITHUB_TOKEN@github.com
__ticket_id="$GITHUB_RUN_ID-$(date +%s)"
echo "::save-state name=ticket_id::$__ticket_id"

set_up_repo "$__server_url/$ARG_REPOSITORY"
enqueue $ARG_BRANCH $__mutex_queue_file $__ticket_id
wait_for_lock $ARG_BRANCH $__mutex_queue_file $__ticket_id

echo "Lock successfully acquired"

time=$(date)
echo "::set-output name=time::$time"

