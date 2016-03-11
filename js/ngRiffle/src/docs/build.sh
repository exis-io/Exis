#!/bin/bash
cat contents.md > ngRiffle.md && \
jsdoc2md riffleProvider.js >> ngRiffle.md && \
cp ngRiffle.md ~/websitev2/docs/API-Reference/ngRiffle.md
