#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <pypi|pypitest>"
    exit 1
fi

# Make sure we have all of the files listed in the manifest.
for f in `cat MANIFEST.in`; do
    if [ "$f" != "include" -a ! -f "$f" ]; then
        echo "$f was not found."
        echo "Run 'make python' on that architecture and aggregate the shared library files."
        exit 1
    fi
done

if [ ! -f ~/.pypirc ]; then
    echo "~/.pypirc was not found."
    exit 1
fi

python setup.py sdist upload --repository $1
