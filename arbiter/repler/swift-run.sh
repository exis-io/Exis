#!/bin/bash

cat >./main/main.swift <<EOF
import Riffle

Riffle.setFabric("$WS_URL")
$EXIS_SETUP

func print(msg: String) {
    Riffle.application(msg)
}

class Tester: Domain {
    override func onJoin() {
        var backend = self

        $EXIS_REPL_CODE
        print("___SETUPCOMPLETE___")
    }
}

let tester = Tester(name: "${DOMAIN}.example")
tester.join()
EOF

LOG="`pwd`/logs"

cd main

# Print build messages to stderr so that we log them.
swift build 2>&1

echo "___BUILDCOMPLETE___"

.build/debug/Example
