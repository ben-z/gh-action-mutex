#!/bin/sh -l

echo "Hello $1"

echo "$GITHUB_REPOSITORY"
echo "$GITHUB_TOKEN"

git status

ls -alh
uname -a

time=$(date)
echo "::set-output name=time::$time"
