#!/bin/bash

swiftc -I. -c riffle.swift  -import-objc-header bridgingHeader.h
swiftc -I. -c main.swift  -import-objc-header bridgingHeader.h

swiftc -emit-library riffle.swift -module-name riffle -import-objc-header bridgingHeader.h
swiftc -emit-module -module-name riffle riffle.swift -import-objc-header bridgingHeader.h

swiftc -o example main.o -L. -lriffmantle -lriffle -lFoundation

# Run
LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH ./example 