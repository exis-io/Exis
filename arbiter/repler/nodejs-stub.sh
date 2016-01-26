#!/bin/bash

cat >main.js <<EOF
// Fake out the onJoin function
setTimeout(function (){
    console.log("Connecting to: " + process.env.WS_URL);
    console.log("Connecting domain: " + process.env.DOMAIN);
    $EXIS_REPL_CODE
    setTimeout(function (){
        console.log("Really long running timeout");
    }, 100000);
}, 1500);
// Fake out a short period that looks like the Join() function
setTimeout(function (){
    console.log("___SETUPCOMPLETE___");
}, 500);
EOF

echo "___BUILDCOMPLETE___"

which nodejs
if [ $? -ne 0 ]; then
    node main.js
else
    nodejs main.js
fi
