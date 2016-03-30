#!/bin/bash
cat contents.md > jsRiffle.md && \
jsdoc2md ../index.js ../src/collections.js >> jsRiffle.md
