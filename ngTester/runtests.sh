$!/bin/bash

function ctrl_c() {
    if [ ! -z "$GRUNT_PID" ]; then
        echo "GRUNT_PID: $GRUNT_PID"
        kill -9 $GRUNT_PID
    fi

}
trap ctrl_c SIGINT

grunt serve &
GRUNT_PID=$!

sleep 5

python runtests.py


