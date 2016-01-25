#!/bin/bash

cat >main.js <<EOF
var riffle = require('jsriffle');

riffle.SetFabric(process.env.WS_URL);

var app = riffle.Domain(process.env.DOMAIN);
var backend = app.Subdomain("example");
var client = app.Subdomain("example");

backend.onJoin = function() {
    $EXIS_REPL_CODE
    console.log("___SETUPCOMPLETE___");
};

backend.Join()
EOF

echo "___BUILDCOMPLETE___"

nodejs main.js
