<div align="center">
    <h1>Join the Chat!
    <br>
    <a href="http://slack.exis.io"><img src="http://slack.exis.io/badge.svg"></a>
    </h3>
</div>

# swiftRiffle (swift 2.2 Open Source)

All our docs live at [docs.exis.io](http://docs.exis.io). 

This is for the open source version of swift. This directory is exploratory and subject to change. 

**1**. Install [Go][https://golang.org/dl/].

**2**. Set a GOPATH: `export GOPATH=some/path/to/go/src`. This is where Go saves download packages. 

**3**. Link core libraries to Gopath: `python stump.py init`. Alternatively, `go get github.com/exis-io/core` may also work, but this won't keep the directory up to date. 

**4**. Compile riffle core. In top level directory: `make swift`. The core libraries are rebuilt every time this make is run. You only have to do it once, at the start, then you can skip to....

**5**. Compile swiftRiffle. In `swift/swiftRiffle`: `make`. Note: if you `make` in the top level directory swiftRiffle is automatically built as well. 

**6**. Compile and run sample project. In `swift/example`: `make` and then `./run`. 


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


### Setting up a App + Backend Manually

These instructions are for setting up a new or existing project with Riffle with a backend. Tested on Xcode 7.3, cocoapods 1.0.0beta5, and swift 2.1.

- Create a new iOS project.
- Create a new target with `File > New > Target`. Make sure to set the type of the target as OSX Command Line Application
- Close the project. Create a new file in the directory you saved the project. Save it as `Podfile` and change it as follows: 

```

use_frameworks!

target :App do
    platform :ios, '9.0'
  pod "Riffle", :path => "../"
end

target :Backend do
    platform :osx, '10.11'
    pod 'Riffle', :path => "../"
end

```

Make sure to replace `App` and `Backend` with your project's target names. The app target is usually the same as the project. The second target name is the same as entered in step 2. 

See the name of all targets by clicking on the blue project icon on the left bar with Xcode open. 

- Run `pod install` in a terminal in the same directory as your project. 
- Open the workspace, not the project (`.xcworkspace`, not `.xcodeproj`
- Open settings for the `Pods` project. Under `Build Settings > Runpaths` for `Riffle-OSX` add the following to `Runpath Search Paths`

```
@executable_path/Riffle-OSX
```

- Set `Embedded Content Contains Swift Code` to `YES` for `Riffle-OSX` in `Build Settings`

## Dev Notes

Starting Xcode with swift 2.2 toolchain: 

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

A much more brutal result of gomobile: 
```
[go install -p=4 -pkgdir=/Users/damouse/code/go/pkg/gomobile/pkg_darwin_arm -tags="" -work github.com/exis-io/core/androidMantle]
[GOOS=darwin GOARCH=arm GOARM=7 CC=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang CXX=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang CGO_CFLAGS=-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS9.2.sdk -arch armv7 CGO_LDFLAGS=-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS9.2.sdk -arch armv7 CGO_ENABLED=1 TMPDIR=/var/folders/jd/8775w60d3yx4nbyl02q3fqhw0000gn/T/gomobile-work-460828926]

[go build -p=4 -pkgdir=/Users/damouse/code/go/pkg/gomobile/pkg_darwin_arm -tags="" -work -buildmode=c-archive -tags=ios -o /var/folders/jd/8775w60d3yx4nbyl02q3fqhw0000gn/T/gomobile-work-460828926/mantle-arm.a /var/folders/jd/8775w60d3yx4nbyl02q3fqhw0000gn/T/gomobile-work-460828926/src/iosbin/main.go]
[GOOS=darwin GOARCH=arm GOARM=7 CC=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang CXX=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang CGO_CFLAGS=-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS9.2.sdk -arch armv7 CGO_LDFLAGS=-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS9.2.sdk -arch armv7 CGO_ENABLED=1 TMPDIR=/var/folders/jd/8775w60d3yx4nbyl02q3fqhw0000gn/T/gomobile-work-460828926]

[go build -p=4 -pkgdir=/Users/damouse/code/go/pkg/gomobile/pkg_darwin_arm64 -tags="" -work -buildmode=c-archive -tags=ios -o /var/folders/jd/8775w60d3yx4nbyl02q3fqhw0000gn/T/gomobile-work-460828926/mantle-arm64.a /var/folders/jd/8775w60d3yx4nbyl02q3fqhw0000gn/T/gomobile-work-460828926/src/iosbin/main.go]
[GOOS=darwin GOARCH=arm64 CC=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang CXX=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang CGO_CFLAGS=-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS9.2.sdk -arch arm64 CGO_LDFLAGS=-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS9.2.sdk -arch arm64 CGO_ENABLED=1 TMPDIR=/var/folders/jd/8775w60d3yx4nbyl02q3fqhw0000gn/T/gomobile-work-460828926]

[go build -p=4 -pkgdir=/Users/damouse/code/go/pkg/gomobile/pkg_darwin_amd64 -tags="" -work -buildmode=c-archive -tags=ios -o /var/folders/jd/8775w60d3yx4nbyl02q3fqhw0000gn/T/gomobile-work-460828926/mantle-amd64.a /var/folders/jd/8775w60d3yx4nbyl02q3fqhw0000gn/T/gomobile-work-460828926/src/iosbin/main.go]
[GOOS=darwin GOARCH=amd64 CC=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang CXX=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang CGO_CFLAGS=-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator9.2.sdk -mios-simulator-version-min=6.1 -arch x86_64 CGO_LDFLAGS=-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator9.2.sdk -mios-simulator-version-min=6.1 -arch x86_64 CGO_ENABLED=1 TMPDIR=/var/folders/jd/8775w60d3yx4nbyl02q3fqhw0000gn/T/gomobile-work-460828926]

xcrun lipo -create -arch armv7 /var/folders/jd/8775w60d3yx4nbyl02q3fqhw0000gn/T/gomobile-work-460828926/mantle-arm.a -arch arm64 /var/folders/jd/8775w60d3yx4nbyl02q3fqhw0000gn/T/gomobile-work-460828926/mantle-arm64.a -arch x86_64 /var/folders/jd/8775w60d3yx4nbyl02q3fqhw0000gn/T/gomobile-work-460828926/mantle-amd64.a -o Mantle.framework/Versions/A/Mantle] [TMPDIR=/var/folders/jd/8775w60d3yx4nbyl02q3fqhw0000gn/T/gomobile-work-460828926]
```


### Tasty PIE 

You need [this patch](https://go-review.googlesource.com/#/c/19206/) to build (kindof) position-independant libraries for iOS and OSX. See details on installing go from source [here](https://golang.org/doc/install/source).

Checkout the go source repo: 

```
git clone https://go.googlesource.com/go
cd go
git checkout master
```

Note that testing was done on the specific commit that patched the issue. You *should* be ok working off `HEAD`, byt YMMV. 

```
git checkout aea4222f673ee9189ba81548978b091004afe994
```

Build go: 

```
cd src
export GOROOT_BOOTSTRAP=~/code/go
./make.bash
```

Note that building go after v1.4 requires an existing go installation. Make sure to replace `GOROOT_BOOTSTRAP` with the directory of your go tree. It should contain `/bin/go`. You can also just patch your current go version, but this is a little more dangerous. 

Once the compilation succeeds, you'll have at least two (and maybe three!) ready to go versions of go. Its generally ok to leave `GOPATH` untouched, since packages haven't changed, but you *must* fiddle with `PATH` to make sure the makefile uses the correct version of go. You could invoke the new go binary directly with `/path/to/patched/bin/go` and avoid messing with your path, but you will have to change the Makefile since it invokes `go build` without specifying a path.

Easiest way:

```
export PATH=/path/to/patched/bin/go:$PATH
```

Make the library and run something in swiftRiffle on OSX. If you see `ld: illegal text-relocation to 'type..eq.[0]string` then things didnt work. 

Tested with go1.6 on OSX 10.11, Xcode 7.3, cocoapods 1.0.0beta5, and swift 2.1 on 3/8/15.

### C Go Run

As of 1.6 the rules for passing pointers over the language boundraries have become [more strict (and safe, of course)](https://tip.golang.org/doc/go1.6). Until such a time as the riffle core bindings are updated, all compilation of C code has to include `GODEBUG=cgocheck=0` as an env flag before the build. 

### Misc

Including vendored statics: http://stackoverflow.com/questions/19481125/add-static-library-to-podspec

Making a fat static with lipo.

```
Building lipo with:  [xcrun lipo -create -arch armv7 /var/folders/qx/62_2kmm174s6njsmk46_rk080000gn/T/gomobile-work-415098175/hello-arm.a -arch arm64 /var/folders/qx/62_2kmm174s6njsmk46_rk080000gn/T/gomobile-work-415098175/hello-arm64.a -arch x86_64 /var/folders/qx/62_2kmm174s6njsmk46_rk080000gn/T/gomobile-work-415098175/hello-amd64.a -o Hello.framework/Versions/A/Hello]
```


