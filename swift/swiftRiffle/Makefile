APP=example

## Note-- this does not build the mantle. Use the makefile in the top level directory for that

all: libRiffle.so riffle.swiftmodule

%.o:%.swift
	swiftc -I. -c $< -import-objc-header bridgingHeader.h

libRiffle.so: Deferred.o riffle.o 
	swiftc -emit-library Deferred.swift riffle.swift -module-name riffle -import-objc-header bridgingHeader.h
	clang -shared -o libRiffle.so Deferred.o riffle.o 

riffle.swiftmodule:	libRiffle.so
	swiftc -emit-module -module-name riffle riffle.swift -import-objc-header bridgingHeader.h

clean:
	rm -rf *.o *.swiftmodule *.swiftdoc libRiffle.so $(APP)