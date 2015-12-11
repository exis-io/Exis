APP=example

## Note-- this does not build the mantle. Use the makefile in the top level directory for that

all:	$(APP)

%.o:%.swift
	swiftc -I. -I../swiftRiffle -c $< 

$(APP):	main.o
	swiftc -o $(APP) main.o -L../swiftRiffle -lriffmantle -lriffle -lFoundation

clean:
	rm -rf *.o *.swiftmodule *.swiftdoc *.so $(APP) 
