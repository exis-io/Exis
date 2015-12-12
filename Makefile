
all: swift osx ios python js

.PHONY: python js clean osx ios


swift: libriffmantle.so
	cp assets/libriffmantle.so swift/swiftRiffle/libriffmantle.so
	cp assets/libriffmantle.h swift/swiftRiffle/libriffmantle.h

	$(MAKE) -C swift/swiftRiffle all
	$(MAKE) -C swift/example all

osx: 
	GOOS=darwin GOARCH=amd64 go build -buildmode=c-archive -o swift/osxCrust/RiffleTest/riffle.a core/cMantle/main.go
	# go build -buildmode=c-archive -o swift/osxCrust/RiffleTest/riffle.a core/cMantle/main.go

	# rm osx/RiffleTest/see.h osx/RiffleTest/see.a
	# mv products/see.h osx/RiffleTest/see.h 
	# mv products/see.a osx/RiffleTest/see.a

# Orphaned-- don't use yet
ios: 
	# Attempt to build a static library cross compiled for ARM. Currently not functional
	# GOARM=7 CGO_ENABLED=1 GOARCH=arm CC_FOR_TARGET=`pwd`/swift/clangwrap.sh CXX_FOR_TARGET=`pwd`/swift/clangwrap.sh go build -buildmode=c-archive -o assets/riffmantle.a core/cMantle/main.go
	# GOARM=7 CGO_ENABLED=1 GOARCH=arm go build -buildmode=c-archive -o assets/riffmantle.a core/cMantle/main.go

	# cp assets/riffmantle.a swift/twopointone/Pod/Classes/riffmantle.a
	# cp assets/riffmantle.h swift/twopointone/Pod/Classes/riffmantle.h

	# Build using gomobile, generating a framework. Orphaned, but may work
	GOGCCFLAGS="--Wl,-no_pie" gomobile bind -ldflags="-extldflags=-pie" -target=ios -work core/cMantle/main.go
	# rm -rf swift/Goriffle.framework
	# mv Goriffle.framework swift/Goriffle.framework

python: 
	gopy bind github.com/exis-io/core/pyMantle
	mv riffle.so python/pyRiffle/riffle/riffle.so
	
# python: libriffmantle.so
# 	cp assets/libriffmantle.so python/pyRiffle/riffle/libriffmantle.so
# 	cp assets/libriffmantle.h python/pyRiffle/riffle/libriffmantle.h

js: 
	gopherjs build -mvw core/jsMantle/main.go
	mv main.js js/jsRiffle/src/go.js
	mv main.js.map js/jsRiffle/src/go.js.map

libriffmantle.so: 
	go build -buildmode=c-shared -o assets/libriffmantle.so core/cMantle/main.go

# riffmantle.a: 
# 	GOOS=darwin GOARCH=amd64 go build -buildmode=c-archive -o assets/riffmantle.a core/cMantle/main.go

clean: 
	rm assets/libriffmantle.so assets/libriffmantle.h
	rm swift/osxCrust/RiffleTest/riffle.a  swift/osxCrust/RiffleTest/riffle.h
	# rm python/pyRiffle/riffle/libriffmantle.so python/pyRiffle/riffle/libriffmantle.h

	$(MAKE) -C swift/container clean


