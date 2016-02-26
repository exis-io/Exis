#!/bin/bash

function cleanup() {
    if [ ! -z "$GRUNT_PID" ]; then
        echo "GRUNT_PID: $GRUNT_PID"
        kill -9 $GRUNT_PID
    fi

    exit 0
}

trap cleanup SIGINT

grunt serve &
GRUNT_PID=$!

sleep 5

python test.py "$@"

cleanup




