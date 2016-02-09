#!/bin/bash

cat >./main/main.swift <<EOF
import Riffle

Riffle.SetFabric("$WS_URL")
$EXIS_SETUP

func print(msg: String) {
    Riffle.ApplicationLog(msg)
}

class Tester: Riffle.Domain, Riffle.Delegate  {
    override func onJoin() {
        var backend = self

        $EXIS_REPL_CODE
        print("___SETUPCOMPLETE___")
    }
}

let tester = Tester(name: "${DOMAIN}.example")
tester.delegate = tester
tester.join()
EOF

LOG="`pwd`/logs"

cd main
swift build >>$LOG 2>&1

echo "___BUILDCOMPLETE___"

.build/debug/Example
