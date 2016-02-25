#!/bin/bash

function ctrl_c() {
    if [ ! -z "$GRUNT_PID" ]; then
        echo "grunt_pid: $GRUNT_PID"
        kill -9 $GRUNT_PID
    fi

    if [ ! -z "$CHROME1_PID" ]; then
        echo "chrome1_pid: $CHROME1_PID"
        kill $CHROME1_PID
    fi

    if [ ! -z "$CHROME2_PID" ]; then
        echo "chrome1_pid: $CHROME2_PID"
        kill $CHROME2_PID
    fi

    exit 0
}

# trap ctrl-c and call ctrl_c()
trap ctrl_c SIGINT

# Start grunt serve in the background
grunt serve &
GRUNT_PID=$!
echo "grunt_pid: $GRUNT_PID"

sleep 10


google-chrome --new-window http://localhost:9001/#/backend &
CHROME1_PID=$!

sleep 5
google-chrome --new-window http://localhost:9001/#/client &
CHROME2_PID=$!


echo "Press [CTRL+C] to stop.."
while true
do
    sleep 1
done

