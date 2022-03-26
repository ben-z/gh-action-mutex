#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "Hello $1"

"$SCRIPT_DIR"/set-up-branch.sh

# echo "$ARG_CHECKOUT_LOCATION"
# echo "$GITHUB_REPOSITORY"
# echo "$GITHUB_TOKEN"
# echo "$ARG_BRANCH"

#git status
#
#ls -alh
#uname -a

time=$(date)
echo "::set-output name=time::$time"

