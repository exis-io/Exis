<div align="center">
    <a href="http://slack.exis.io"><img src="http://slack.exis.io/badge.svg"></a>
    </h3>
</div>

All our docs live at [docs.exis.io](http://docs.exis.io). This directory holds both the open source and iOS versions of swiftRiffle. 

### Setting up a App + Backend Manually

These instructions are for setting up a new or existing project with Riffle with a backend. Tested on Xcode 7.3, cocoapods 1.0.0beta5, and swift 2.1.

- Create a new iOS project.
- Create a new target with `File > New > Target`. Make sure to set the type of the target as OSX Command Line Application
- Close the project. Create a new file in the directory you saved the project. Save it as `Podfile` and change it as follows: 

```

use_frameworks!

target :ExisiOSBackend do
    platform :ios, '9.0'
    pod "Riffle", :git => 'https://github.com/exis-io/swiftRiffleCocoapod'
end

target :Backend do
    platform :osx, '10.11'
    pod 'Riffle', :git => 'https://github.com/exis-io/swiftRiffleCocoapod'
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


# swiftRiffle (swift 2.2 Open Source)

This is for the open source version of swift. This directory is exploratory and subject to change. 

**1**. Install [Go][https://golang.org/dl/].

**2**. Set a GOPATH: `export GOPATH=some/path/to/go/src`. This is where Go saves download packages. 

**3**. Link core libraries to Gopath: `python stump.py init`. Alternatively, `go get github.com/exis-io/core` may also work, but this won't keep the directory up to date. 

**4**. Compile riffle core. In top level directory: `make swift`. The core libraries are rebuilt every time this make is run. You only have to do it once, at the start, then you can skip to....

**5**. Compile swiftRiffle. In `swift/swiftRiffle`: `make`. Note: if you `make` in the top level directory swiftRiffle is automatically built as well. 

**6**. Compile and run sample project. In `swift/example`: `make` and then `./run`. 

**GCD**, Grand Central Dispatch, is Swift's high level threading mechanism. You will need to build it seperately from swift. 

```
sudo apt-get install autoconf libtool pkg-config libblocksruntime-dev libkqueue-dev libpthread-workqueue-dev systemtap-sdt-dev libbsd-dev libbsd0 libbsd0-dbg
git clone --recursive https://github.com/apple/swift-corelibs-libdispatch.git
cd swift-corelibs-libdispatch
sh autogen.sh
./configure
make
```

Use the following when executing swift executables that link with GCD (anything that imports Riffle).

```
swift build -Xcc -fblocks -Xlinker -ldispatch
```

As of the time of this writing the above command doesnt work. Something is missing. Note the following output from the result of the installation.

```
Libraries have been installed in:
   /home/damouse/.swiftenv/DEVELOPMENT-SNAPSHOT-2016-03-01-a/usr/lib/swift/linux

If you ever happen to want to link against installed libraries
in a given directory, LIBDIR, you must either use libtool, and
specify the full pathname of the library, or use the `-LLIBDIR'
flag during linking and do at least one of the following:
   - add LIBDIR to the `LD_LIBRARY_PATH' environment variable
     during execution
   - add LIBDIR to the `LD_RUN_PATH' environment variable
     during linking
   - use the `-Wl,-rpath -Wl,LIBDIR' linker flag
   - have your system administrator add LIBDIR to `/etc/ld.so.conf'

```

Also note an upstream commit to libdispatch installation instructions.

```
sh autogen.sh
./configure CC=clang --with-blocks-runtime=/usr/local/lib
make check
```

`make check` doesn't work on my system. Suspect an issue with swiftenv. According to (this)[http://stackoverflow.com/questions/34680816/swift-in-linux-use-of-unresolved-identifier-dispatch-async] SO answer libdispatch doesn't play nicely with `swift build` yet. 

(alwaysrightinstitute)[http://www.alwaysrightinstitute.com/swift-multi-module-dev/] seems to be working on a wrapper around the library so swift build can still be used. 

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

