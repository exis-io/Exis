## Note-- this does not build the mantle. Use the makefile in the top level directory for that

# .PHONY: libRiffle.so riffle.swiftmodule

all: libRiffle.so riffle.swiftmodule

# emit-dependencies doesnt work 

%.o:%.swift
	swiftc -I. -c $< -import-objc-header bridgingHeader.h

libRiffle.so: riffle.o 
	swiftc -emit-library riffle.swift -module-name riffle -import-objc-header bridgingHeader.h
	clang -shared -o libRiffle.so riffle.o 

riffle.swiftmodule:	libRiffle.so
	swiftc -emit-module -module-name riffle riffle.swift -import-objc-header bridgingHeader.h

clean:
	rm -rf *.o *.swiftmodule *.swiftdoc libRiffle.so 