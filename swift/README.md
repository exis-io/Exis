<div align="center">
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

Note: occasionally Xcode can get a little greedy, build the framework ahead of time, and ignore the settings above after. If you'be made these changes and see see errors about linking libraries, delete your derived data directory. 

```
rm -rf ~/Library/Developer/Xcode/DerivedData
```

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

### Cocoapods

Cocoapods has issues with the compiled go libraries. It validates them at the following path: 

```
Line 58: ~/.vm/gems/ruby-2.2.1/gems/cocoapods-1.0.0.beta.5/lib/cocoapods/command/repo/push.rb
```

