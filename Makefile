
all: swift osx ios python js

.PHONY: python js clean 


swift: libriffmantle.so
	cp assets/libriffmantle.so swift/container/libriffmantle.so
	cp assets/libriffmantle.h swift/container/libriffmantle.h

	$(MAKE) -C swift/container all


python: libriffmantle.so
	cp assets/libriffmantle.so python/pyRiffle/riffle/libriffmantle.so
	cp assets/libriffmantle.h python/pyRiffle/riffle/libriffmantle.h


js: 
	gopherjs build -mvw go/coreRiffle/mantles/jsRiffle.go
	mv jsRiffle.js js/jsRiffle/src/go.js
	mv jsRiffle.js.map js/jsRiffle/src/go.js.map


libriffmantle.so: 
	go build -buildmode=c-shared -o assets/libriffmantle.so go/coreRiffle/mantles/see.go


clean: 
	rm assets/libriffmantle.so assets/libriffmantle.h
	# rm python/pyRiffle/riffle/libriffmantle.so python/pyRiffle/riffle/libriffmantle.h

	$(MAKE) -C swift/container clean


# Orphaned code-- don't use yet
osx: 
	GOOS=darwin GOARCH=amd64 go build -buildmode=c-archive -o swift/osxCrust/RiffleTest/see.a goriffle/runner/see.go
	# rm osx/RiffleTest/see.h osx/RiffleTest/see.a
	# mv products/see.h osx/RiffleTest/see.h 
	# mv products/see.a osx/RiffleTest/see.a

ios: 
	GOGCCFLAGS="--Wl,-no_pie" gomobile bind -ldflags="-extldflags=-pie" -target=ios -work github.com/exis-io/goriffle
	rm -rf swift/Goriffle.framework
	mv Goriffle.framework swift/Goriffle.framework