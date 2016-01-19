#!/bin/bash

export PATH=$PATH:/usr/local/go/bin

if ! command -v go >/dev/null; then
    echo "go not found"
    exit 1
fi

cd core
go test --cover

exit $?
