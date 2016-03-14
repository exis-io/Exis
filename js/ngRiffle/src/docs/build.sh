#!/bin/bash
cat contents.md > ngRiffle.md && \
jsdoc2md ../ngRiffle.js >> ngRiffle.md
