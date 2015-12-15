
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
	# Build using gomobile, generating a framework. Orphaned, but may work

	# Run directly
	# go run ~/code/go/src/golang.org/x/mobile/cmd/gomobile/bind.go -target=ios github.com/exis-io/core/iosMantle

	gomobile bind -target=ios github.com/exis-io/core/iosMantle
	rm -rf swift/iosCrust/RiffleTesterIos/IosMantle.framework
	mv IosMantle.framework swift/iosCrust/RiffleTesterIos/IosMantle.framework

	# Attempt to build a static library cross compiled for ARM. Currently not functional
	# GOARM=7 CGO_ENABLED=1 GOARCH=arm CC_FOR_TARGET=`pwd`/swift/clangwrap.sh CXX_FOR_TARGET=`pwd`/swift/clangwrap.sh go build -buildmode=c-archive -o assets/riffmantle.a core/cMantle/main.go
	# GOARM=7 CGO_ENABLED=1 GOARCH=arm go build -buildmode=c-archive -o assets/riffmantle.a core/cMantle/main.go

	# cp assets/riffmantle.a swift/twopointone/Pod/Classes/riffmantle.a
	# cp assets/riffmantle.h swift/twopointone/Pod/Classes/riffmantle.h
	

python: 
	gopy bind github.com/exis-io/core/pyMantle
	mv riffle.so python/pyRiffle/riffle/riffle.so
	
# python: libriffmantle.so
# 	cp assets/libriffmantle.so python/pyRiffle/riffle/libriffmantle.so
# 	cp assets/libriffmantle.h python/pyRiffle/riffle/libriffmantle.h

js: 
	gopherjs build -mv core/jsMantle/main.go
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


# To debug and extract the build commands, check golang.org/x/mobile/cmd/gomobile/bind_iosapp.go
# This is where the commands are emitted to create the library 
#
# Make changes, then 'go install' in golang.org/x/mobile/cmd/gomobile