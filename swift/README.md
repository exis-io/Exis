# swiftRiffle (swift 2.2 Open Source)

All our docs live at [docs.exis.io](http://docs.exis.io). 

This is for the open source version of swift. This directory is exploratory and subject to change. 

**1**. Install [Go][https://golang.org/dl/].

**2**. Set a GOPATH: `export GOPATH=some/path/to/go/src`. This is where Go saves download packages. 

**3**. Link core libraries to Gopath: `python stump.py init`. Alternatively, `go get github.com/exis-io/core` may also work, but this won't keep the directory up to date. 

**4**. Compile riffle core. In top level directory: `make swift`. The core libraries are rebuilt every time this make is run. You only have to do it once, at the start, then you can skip to....

**5**. Compile swiftRiffle. In `swift/swiftRiffle`: `make`. Note: if you `make` in the top level directory swiftRiffle is automatically built as well. 

**6**. Compile and run sample project. In `swift/example`: `make` and then `./run`. 


## Notes

Starting Xcode with 2.2 toolchain: 

```
xcrun launch-with-toolchain /Library/Developer/Toolchains/swift-latest.xctoolchain
```

## Troubleshooting

### "/usr/bin/ld: cannot find -lstdc++"

If you see this error message while running `make swift` on Ubuntu 14.04, try the following command.

```
sudo ln -s /usr/lib/x86_64-linux-gnu/libstdc++.so.6 /usr/lib/x86_64-linux-gnu/libstdc++.so
```

Then run `make clean` and try `make swift` again.

Building a [fat lib](https://peawee.net/posts/158/) for multiple platforms. 

Result of gomobile: 
```
Args to build:  [GOOS=darwin GOARCH=arm GOARM=7 CC=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang CXX=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang CGO_CFLAGS=-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS9.2.sdk -arch armv7 CGO_LDFLAGS=-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS9.2.sdk -arch armv7 CGO_ENABLED=1] arm

Args to build:  [GOOS=darwin GOARCH=arm64 CC=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang CXX=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang CGO_CFLAGS=-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS9.2.sdk -arch arm64 CGO_LDFLAGS=-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS9.2.sdk -arch arm64 CGO_ENABLED=1] arm64

Args to build:  [GOOS=darwin GOARCH=amd64 CC=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang CXX=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang CGO_CFLAGS=-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator9.2.sdk -mios-simulator-version-min=6.1 -arch x86_64 CGO_LDFLAGS=-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator9.2.sdk -mios-simulator-version-min=6.1 -arch x86_64 CGO_ENABLED=1] amd64
```


### Custom Patch Check

Grabbed the patch from: https://go-review.googlesource.com/#/c/19206/. Dropped into gvm dir, set goroot to 1.5, manually applied patch, and rebuilt. Didn't work in the end, not sure if its the fault of the patch or not. 

Including vendored statics: http://stackoverflow.com/questions/19481125/add-static-library-to-podspec

Making a fat static with lipo.

```
Building lipo with:  [xcrun lipo -create -arch armv7 /var/folders/qx/62_2kmm174s6njsmk46_rk080000gn/T/gomobile-work-415098175/hello-arm.a -arch arm64 /var/folders/qx/62_2kmm174s6njsmk46_rk080000gn/T/gomobile-work-415098175/hello-arm64.a -arch x86_64 /var/folders/qx/62_2kmm174s6njsmk46_rk080000gn/T/gomobile-work-415098175/hello-amd64.a -o Hello.framework/Versions/A/Hello]
```


# swiftRiffle

This directory contains the swiftRiffle client libraries and a set of preconfigured projects for development on iOS and OSX.

Riffle requries at least iOS 8.0, OSX 10.10, and Swift 2.1. Please check out *Known Issues* below for troubleshooting. 

### iOS Apps

This is only for the development of iOS apps. 

[Download a zip](https://github.com/exis-io/iosAppSeed). 

Clone the project from github:

```
git clone https://github.com/exis-io/iosAppSeed.git
```

Install using Cocoapods: 

```
platform :ios, '9.0'
use_frameworks!
pod 'Riffle'
```

### iOS Apps And Backends

This is for the development of iOS apps and swift backends. 

[Download a zip](https://github.com/exis-io/iosAppBackendSeed/archive/master.zip) 

Clone the project from github:

```
git clone https://github.com/exis-io/iosAppBackendSeed.git
```

Replace `ExisiOSBackend` and `Backend` with the target name of your app and backend, respectively. Cocoapods: 

```
use_frameworks!

target :ExisiOSBackend, :exclusive => true do
  platform :ios, '9.0'
  pod 'Riffle'
end

target :Backend, :exclusive => true do
  platform :osx, '10.10'
  pod 'Riffle'
end
```


