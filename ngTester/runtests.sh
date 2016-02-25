#!/bin/bash

WAITTIME=20

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

python test.py

ENDTIME=$((SECONDS+WAITTIME))

while [ $SECONDS -lt $ENDTIME ]; do
    sleep 1
done

cleanup




