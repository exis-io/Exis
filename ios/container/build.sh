#!/bin/bash

swiftc -I. -c translator.swift  -import-objc-header bridgingHeader.h
swiftc -I. -c main.swift  -import-objc-header bridgingHeader.h

swiftc -emit-library translator.swift -module-name translator -import-objc-header bridgingHeader.h
swiftc -emit-module -module-name translator translator.swift -import-objc-header bridgingHeader.h

swiftc -o biddly main.o -L. -lriff -ltranslator -lFoundation

# Run
LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH ./biddly 