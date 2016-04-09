
all: swift ios python js

.PHONY: python js clean osx ios java android

LOG="./build.log"

# Directories
SWIFT_EXAMPLE=swift/example
SWIFT_RIFFLE=swift/swiftRiffle/Pod/Classes

IOS_DIR=-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS9.3.sdk
SIM_DIR=-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator9.3.sdk 
CLANG_DIR=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang

printcheck:
	@>$(LOG)
	@echo "Check $(LOG) for warnings and errors"

swift: printcheck libriffmantle.so
	@$(MAKE) -C swift/mantle clean >$(LOG) ||:
	@rm -rf ${SWIFT_RIFFLE}/.git

	@cp utils/assets/libriffmantle.so swift/mantle/libriffmantle.so
	@cp utils/assets/libriffmantle.h swift/mantle/libriffmantle.h

	@echo "Installing mantle..."
	@$(MAKE) -C swift/mantle all >>$(LOG)

	# The package has to be tagged to so SPM can resolve a dependency
	@echo "Installing crust..."
	@git -C ${SWIFT_RIFFLE} init
	@git -C ${SWIFT_RIFFLE} add .
	@git -C ${SWIFT_RIFFLE} commit -m "Package setup"
	@git -C ${SWIFT_RIFFLE} tag 1.0.0

	@echo "To build the example, run make swift_example"

swift_example: printcheck 
	@rm -rf ${SWIFT_EXAMPLE}/Pacakges
	@echo "Building example..."
	@swift build --chdir swift/example
	@echo "Now 'cd swift/example' and run './.build/debug/Example', 'SENDER=true ./.build/debug/Example'"

ios:
	@echo "Building arm7" 
	@GOOS=darwin GOARCH=arm GOARM=7 CC=${CLANG_DIR} CXX={CLANG_DIR} CGO_ENABLED=1 \
	CGO_CFLAGS='${IOS_DIR} -arch armv7' CGO_LDFLAGS='${IOS_DIR} -arch armv7' \
	go build -p=4 -pkgdir=/Users/damouse/code/go/pkg/gomobile/pkg_darwin_arm -tags="" -buildmode=c-archive -tags=ios -o .tmp/riffle-arm.a core/cMantle/main.go

	@echo "Building arm64" 
	@GOOS=darwin GOARCH=arm64 CC=${CLANG_DIR} CXX={CLANG_DIR} CGO_ENABLED=1 \
	CGO_CFLAGS='${IOS_DIR} -arch arm64' CGO_LDFLAGS='${IOS_DIR} -arch arm64' \
	go build -p=4 -pkgdir=/Users/damouse/code/go/pkg/gomobile/pkg_darwin_arm -tags="" -buildmode=c-archive -tags=ios -o .tmp/riffle-arm64.a core/cMantle/main.go

	@echo "Building x86_64 (simulator)" 
	@GOOS=darwin GOARCH=amd64 CC=${CLANG_DIR} CXX={CLANG_DIR} CGO_ENABLED=1 \
	CGO_CFLAGS="${SIM_DIR} -miphoneos-version-min=9.0 -mios-simulator-version-min=6.1 -arch x86_64" \
	CGO_LDFLAGS="${SIM_DIR} -miphoneos-version-min=9.0 -mios-simulator-version-min=6.1 -arch x86_64" \
	go build -p=4 -pkgdir=/Users/damouse/code/go/pkg/gomobile/pkg_darwin_arm -tags="" -buildmode=c-archive -tags=ios -o .tmp/riffle-x86_64_ios.a core/cMantle/main.go

	@echo "Building i386 (simulator)" 
	@GOOS=darwin GOARCH=386 CC=${CLANG_DIR} CXX={CLANG_DIR} CGO_ENABLED=1 \
	CGO_CFLAGS="${SIM_DIR} -miphoneos-version-min=9.0 -mios-simulator-version-min=6.1 -arch i386" \
	CGO_LDFLAGS="${SIM_DIR} -miphoneos-version-min=9.0 -mios-simulator-version-min=6.1 -arch i386" \
	go build -p=4 -pkgdir=/Users/damouse/code/go/pkg/gomobile/pkg_darwin_arm -tags="" -buildmode=c-archive -tags=ios -o .tmp/riffle-x86_32_ios.a core/cMantle/main.go

	@echo "Combining with lipo" 
	@xcrun lipo -create .tmp/riffle-arm.a .tmp/riffle-arm64.a .tmp/riffle-x86_64_ios.a .tmp/riffle-x86_32_ios.a -o swift/swiftRiffle/Pod/Assets/ios/Mantle.framework/Versions/A/Mantle
	@mv .tmp/riffle-arm.h swift/swiftRiffle/Pod/Assets/ios/Mantle.framework/Versions/A/Headers/Mantle.h
 
	@echo "Building x86 (command line)" 
	@GOOS=darwin GOARCH=amd64 go build -buildmode=c-archive -o .tmp/riffle-x86_64_osx.a core/cMantle/main.go
	@mv .tmp/riffle-x86_64_osx.h swift/swiftRiffle/Pod/Assets/osx/Mantle.framework/Versions/A/Headers/Mantle.h
	@mv .tmp/riffle-x86_64_osx.a swift/swiftRiffle/Pod/Assets/osx/Mantle.framework/Versions/A/Mantle

	@# make sure this doesnt cause problem on vanilla arm7
	@sed -i.gobak '/_check_for_32/d' ./swift/swiftRiffle/Pod/Assets/ios/Mantle.framework/Versions/A/Headers/Mantle.h

android:
	@echo "Building core..."
	@gomobile bind -target=android github.com/exis-io/core/androidMantle

	@# Doesn't use the AAR directly because it screws with distribution
	@echo "Moving mantle"
	@rm -rf .tmp/android
	@mkdir -p .tmp/android
	@unzip mantle.aar -d .tmp/android
	@rm mantle.aar

	@rm -f java/droidRiffle/riffle/libs/classes.jar
	@rm -rf java/droidRiffle/riffle/src/main/jniLibs
	@mkdir -p java/droidRiffle/riffle/libs/
	@mv .tmp/android/classes.jar java/droidRiffle/riffle/libs/classes.jar
	@mv .tmp/android/jni java/droidRiffle/riffle/src/main/jniLibs

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
	@-rm -rf .tmp

	@-rm -f utils/assets/libriffmantle.so utils/assets/libriffmantle.h >$(LOG) ||:
	@$(MAKE) -C swift/mantle clean >$(LOG) ||:
	@rm -rf ${SWIFT_RIFFLE}/.git
	@rm -rf swift/example/Packages >$(LOG) ||:

