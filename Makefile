
all: swift ios python js

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

ios:
	@echo "Building arm7" 
	@GOOS=darwin GOARCH=arm GOARM=7 \
	CC=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang \
	CXX=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang \
	CGO_CFLAGS='-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS9.2.sdk -arch armv7' \
	CGO_LDFLAGS='-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS9.2.sdk -arch armv7' \
	CGO_ENABLED=1 \
	go build -p=4 -pkgdir=/Users/damouse/code/go/pkg/gomobile/pkg_darwin_arm -tags="" -buildmode=c-archive -tags=ios -o .tmp/riffle-arm.a core/cMantle/main.go

	@echo "Building arm64" 
	@GOOS=darwin GOARCH=arm64 \
	CC=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang \
	CXX=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang \
	CGO_CFLAGS='-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS9.2.sdk -arch arm64' \
	CGO_LDFLAGS='-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS9.2.sdk -arch arm64' \
	CGO_ENABLED=1 \
	go build -p=4 -pkgdir=/Users/damouse/code/go/pkg/gomobile/pkg_darwin_arm -tags="" -buildmode=c-archive -tags=ios -o .tmp/riffle-arm64.a core/cMantle/main.go

	@echo "Building x86 (simulator)" 
	@GOOS=darwin GOARCH=amd64 \
	CC=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang \
	CXX=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang \
	CGO_CFLAGS="-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator9.2.sdk -miphoneos-version-min=9.0 -mios-simulator-version-min=6.1 -arch x86_64" \
	CGO_LDFLAGS="-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator9.2.sdk -miphoneos-version-min=9.0 -mios-simulator-version-min=6.1 -arch x86_64" \
	CGO_ENABLED=1 \
	go build -p=4 -pkgdir=/Users/damouse/code/go/pkg/gomobile/pkg_darwin_arm -tags="" -buildmode=c-archive -tags=ios -o .tmp/riffle-x86_64_ios.a core/cMantle/main.go

	@echo "Combining with lipo" 
	@xcrun lipo -create .tmp/riffle-arm.a .tmp/riffle-arm64.a .tmp/riffle-x86_64_ios.a -o swift/iosRiffle/Pod/Assets/ios/Mantle.framework/Versions/A/Mantle
	@mv .tmp/riffle-arm.h swift/iosRiffle/Pod/Assets/ios/Mantle.framework/Versions/A/Headers/Mantle.h

	@echo "Building x86 (command line)" 
	@GOOS=darwin GOARCH=amd64 go build -buildmode=c-archive -o .tmp/riffle-x86_64_osx.a core/cMantle/main.go
	@mv .tmp/riffle-x86_64_osx.h swift/iosRiffle/Pod/Assets/osx/Mantle.framework/Versions/A/Headers/Mantle.h
	@mv .tmp/riffle-x86_64_osx.a swift/iosRiffle/Pod/Assets/osx/Mantle.framework/Versions/A/Mantle

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
	@-rm -rf .tmp

	@-rm -f utils/assets/libriffmantle.so utils/assets/libriffmantle.h >$(LOG) ||:
	@$(MAKE) -C swift/mantle clean >$(LOG) ||:
	@$(MAKE) -C swift/swiftRiffle/Riffle clean >$(LOG) ||:
	@rm -rf swift/example/Packages >$(LOG) ||:




