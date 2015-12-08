APP=example

## Note-- this does not build the mantle. Use the makefile in the top level directory for that

all:	$(APP)

%.o:%.c
	clang -c $<

%.o:%.swift
	swiftc -I. -c $< -import-objc-header bridgingHeader.h

$(APP):	libriffle.so riffle.swiftmodule main.o
	swiftc -o $(APP) main.o -L. -lriffmantle -lriffle -lFoundation

libriffle.so:	riffle.o
	swiftc -emit-library riffle.swift -module-name riffle -import-objc-header bridgingHeader.h
	clang -shared -o libriffle.so riffle.o

riffle.swiftmodule:	libriffle.so
	swiftc -emit-module -module-name riffle riffle.swift -import-objc-header bridgingHeader.h

clean:
	rm -rf *.o *.swiftmodule *.swiftdoc *.so $(APP) libriffmantle.h
