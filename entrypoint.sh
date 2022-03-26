#!/bin/sh -l

echo "Hello $1"

ls -alh
uname -a

time=$(date)
echo "::set-output name=time::$time"
