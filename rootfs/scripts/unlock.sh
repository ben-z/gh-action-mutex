#!/bin/bash

# TODO: remove
echo "Goodbye $1"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source "$SCRIPT_DIR/utils.sh"

echo "STATE_ticket_id"

echo "Lock successfully acquired"

