#!/bin/bash
#
# Run the unit tests and produce HTML output.
#
go test -covermode=count -coverprofile=count.out && go tool cover -html=count.out
