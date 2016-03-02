
all: swift osx ios python js

.PHONY: python js clean osx ios java android

LOG="./build.log"

printcheck:
	@>$(LOG)
	@echo "Check $(LOG) for warnings and errors"

swift: printcheck libriffmantle.so
	@cp utils/assets/libriffmantle.so swift/mantle/libriffmantle.so
	@cp utils/assets/libriffmantle.h swift/mantle/libriffmantle.h

	@echo "Installing mantle..."
	@$(MAKE) -C swift/mantle all >>$(LOG)

	@echo "Installing crust..."
	@$(MAKE) -C swift/swiftRiffle/Riffle all >>$(LOG)

	@echo "To build the example, run make swift_example"

swift_example: printcheck libriffmantle.so
	@echo "Building example..."
	@swift build --chdir swift/example
	@echo "Now 'cd swift/example' and run './.build/debug/Example', 'SENDER=true ./.build/debug/Example'"

osx: 
	GOOS=darwin GOARCH=amd64 go build -buildmode=c-archive -o swift/swiftRiffle/riffle.a core/cMantle/main.go

android:
	@echo "Building core..."
	@gomobile bind --work -target=android github.com/exis-io/core/androidMantle
	@echo "Moving mantle"
	@mv mantle.aar java/droidRiffle/mantle/mantle.aar

android86:
	@echo "Building core..."
	@go build -buildmode=c-shared -o java/testing/libmantle.so core/cMantle/main.go

androidtestarm:
	GOOS=android \
	GOARCH=arm \
	GOARM=7 \
	CC=/home/damouse/code/go/pkg/gomobile/android-ndk-r10e/arm/bin/arm-linux-androideabi-gcc \
	CXX=/home/damouse/code/go/pkg/gomobile/android-ndk-r10e/arm/bin/arm-linux-androideabi-g++ \
	CGO_ENABLED=1 \
	go build -buildmode=c-shared -o java/droidRiffle/app/src/main/jniLibs/armeabi-v7a/libmeth.so java/testing/meth.go

javatest: 
	@echo "Building core..."
	@go build -buildmode=c-shared -o java/droidRiffle/app/src/main/jniLibs/x86/libmeth.so java/testing/meth.go
	@cp java/droidRiffle/app/src/main/jniLibs/x86_64/libmeth.so java/testing/libmeth.so
	@cp java/droidRiffle/app/src/main/jniLibs/x86_64/libmeth.h java/testing/libmeth.h

java: 
	@echo "Building core..."
	@go build -buildmode=c-shared -o libgojni.so core/androidMantle/main.go

python: 
	gopy bind github.com/exis-io/core/pyMantle
	mv pymantle.so python/pyRiffle/riffle/pymantle.so

js: 
	gopherjs build -mv core/jsMantle/main.go
	mv main.js js/jsRiffle/src/go.js
	rm main.js.map

jsbrowser: js
	browserify js/jsRiffle/index.js --standalone jsRiffle -o js/jsRiffle/release/jsRiffle.js
	uglifyjs js/jsRiffle/release/jsRiffle.js -o js/jsRiffle/release/jsRiffle.min.js

libriffmantle.so: 
	@echo "Building core..."
	@go build -buildmode=c-shared -o utils/assets/libriffmantle.so core/cMantle/main.go

clean: 
	@-rm -f utils/assets/libriffmantle.so utils/assets/libriffmantle.h
	@-rm -f swift/osxCrust/RiffleTest/riffle.a  swift/osxCrust/RiffleTest/riffle.h

	@-rm -f utils/assets/libriffmantle.so utils/assets/libriffmantle.h >$(LOG) ||:
	@$(MAKE) -C swift/mantle clean >$(LOG) ||:
	@$(MAKE) -C swift/swiftRiffle/Riffle clean >$(LOG) ||:
	@rm -rf swift/example/Packages >$(LOG) ||:


