
all: swift osx ios python js

swift: 
	go build -buildmode=c-shared -o swift/container/libriff.so go/coreRiffle/wrappers/see.go

python:
	go build -buildmode=c-shared -o python/pyRiffle/riffle/libriff.so go/coreRiffle/wrappers/see.go

js: 
	gopherjs build -mvw go/coreRiffle/wrappers/jsRiffle.go
	mv jsRiffle.js js/jsRiffle/src/go.js
	mv jsRiffle.js.map js/jsRiffle/src/go.js.map

clean: 
	rm swift/container/libriffle.so
	rm swift/container/libriffle.h

# This doesn't work-- need the arm bindings?
# ios-native:
# 	GOARM=7 CGO_ENABLED=1 GOARCH=arm go build -buildmode=c-archive -o products/ios.a goriffle/runner/osx.go


# Orphaned code-- don't use yet
osx: 
	GOOS=darwin GOARCH=amd64 go build -buildmode=c-archive -o swift/osxCrust/RiffleTest/see.a goriffle/runner/see.go
	# rm osx/RiffleTest/see.h osx/RiffleTest/see.a
	# mv products/see.h osx/RiffleTest/see.h 
	# mv products/see.a osx/RiffleTest/see.a

# Orphaned code-- don't use yet
ios: 
	GOGCCFLAGS="--Wl,-no_pie" gomobile bind -ldflags="-extldflags=-pie" -target=ios -work github.com/exis-io/goriffle
	rm -rf swift/Goriffle.framework
	mv Goriffle.framework swift/Goriffle.framework