
all: swift osx ios python js

.PHONY: python js clean osx ios java android

LOG="./build.log"

printcheck:
	@>$(LOG)
	@echo "Check $(LOG) for warnings and errors"

swift: printcheck libriffmantle.so
	@cp assets/libriffmantle.so swift/mantle/libriffmantle.so
	@cp assets/libriffmantle.h swift/mantle/libriffmantle.h

	@echo "Installing mantle..."
	@$(MAKE) -C swift/mantle all >>$(LOG)

	@echo "Installing crust..."
	@$(MAKE) -C swift/swiftRiffle/Riffle all >>$(LOG)

	@echo "Building example..."
	@swift build --chdir swift/example
	@echo "Now 'cd swift/example' and run './.build/debug/Example', 'SENDER=true ./.build/debug/Example'"

osx: 
	GOOS=darwin GOARCH=amd64 go build -buildmode=c-archive -o swift/swiftRiffle/riffle.a core/cMantle/main.go

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

android:
	@echo "Building core..."
	@gomobile bind -target=android github.com/exis-io/core/androidMantle
	@mv mantle.aar java/droidRiffle/mantle/mantle.aar

java: 
	@echo "Building core..."
	@go build -buildmode=c-shared -o java/javaRiffle/libmantle.so core/javaMantle/main.go

python: 
	gopy bind github.com/exis-io/core/pyMantle
	mv pymantle.so python/pyRiffle/riffle/pymantle.so

js: 
	gopherjs build -mv core/jsMantle/main.go
	mv main.js js/jsRiffle/src/go.js
	mv main.js.map js/jsRiffle/src/go.js.map

jsbrowser: js
	browserify js/jsRiffle/index.js --standalone jsRiffle -o js/jsRiffle/release/jsRiffle.js
	browserify js/jsRiffle/index.js --standalone jsRiffle | uglifyjs > js/jsRiffle/release/jsRiffle.min.js

libriffmantle.so: 
	@echo "Building core..."
	@go build -buildmode=c-shared -o assets/libriffmantle.so core/cMantle/main.go

clean: 
	@-rm -f assets/libriffmantle.so assets/libriffmantle.h
	@-rm -f swift/osxCrust/RiffleTest/riffle.a  swift/osxCrust/RiffleTest/riffle.h

	@-rm -f assets/libriffmantle.so assets/libriffmantle.h >$(LOG) ||:
	@$(MAKE) -C swift/mantle clean >$(LOG) ||:
	@$(MAKE) -C swift/swiftRiffle/Riffle clean >$(LOG) ||:
	@rm -rf swift/example/Packages >$(LOG) ||:


# To debug and extract the build commands, check golang.org/x/mobile/cmd/gomobile/bind_iosapp.go
# This is where the commands are emitted to create the library 
#
# Make changes, then 'go install' in golang.org/x/mobile/cmd/gomobile
