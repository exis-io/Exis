APP=translate.exe

all:	$(APP)

%.o:%.c
	clang -c $<

%.o:%.swift
	swiftc -I. -c $< -import-objc-header bridgingHeader.h

$(APP):	libtranslator.so translator.swiftmodule jsonparse.o main.o
	swiftc -o $(APP) jsonparse.o main.o -L. -ltranslator -lcurl -ljson-c -lswiftGlibc -lFoundation

libtranslator.so:	translator.o
	swiftc -emit-library translator.swift -module-name translator -import-objc-header bridgingHeader.h
	clang -shared -o libtranslator.so translator.o

translator.swiftmodule:	libtranslator.so
	swiftc -emit-module -module-name translator translator.swift -import-objc-header bridgingHeader.h

clean:
	rm -rf *.o *.swiftmodule *.swiftdoc *.so $(APP)
