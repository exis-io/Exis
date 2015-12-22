
## Note-- this does not build the mantle. Use the makefile in the top level directory for that

all: sender receiver

%.o:%.swift
	swiftc -I. -I../swiftRiffle -c $< 

sender:	sender.o
	swiftc -o sender sender.o -L../swiftRiffle -lriffmantle -lriffle -lFoundation

receiver: receiver.o
	swiftc -o receiver receiver.o -L../swiftRiffle -lriffmantle -lriffle -lFoundation

clean:
	rm -rf *.o *.swiftmodule *.swiftdoc *.so sender receiver
