#!/bin/bash

export PATH=$PATH:/usr/local/go/bin

if ! command -v go >/dev/null; then
    echo "go not found"
    exit 1
fi

# Use a local directory if GOPATH is not configured.
if [ -z "$GOPATH" ]; then
    export GOPATH=$(pwd)/_go
fi

cd core
go get -d -t .
go test --cover

exit $?
