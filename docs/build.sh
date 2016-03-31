#!/bin/bash
cat contents.md > ngRiffle.md && \
jsdoc2md ../src/ngRiffle.js >> ngRiffle.md
