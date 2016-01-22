#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <pypi|pypitest>"
    exit 1
fi

if [ ! -f riffle/pymantle.so ]; then
    echo "pymantle.so was not found."
    echo "Please run 'make python' in the top-level directory."
    exit 1
fi

if [ ! -f ~/.pypirc ]; then
    echo "~/.pypirc was not found."
    exit 1
fi

python setup.py sdist upload --repository $1
