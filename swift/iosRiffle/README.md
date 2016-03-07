<div align="center">
    <h1>Join the Chat!
    <br>
    <a href="http://slack.exis.io"><img src="http://slack.exis.io/badge.svg"></a>
    </h3>
</div>

# swiftRiffle

This directory contains the swiftRiffle client libraries and a set of preconfigured projects. 

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


## Known Issues

In progress.

## Developing with iosRiffle

`iosRiffle` is *not* meant to be developed as a standalone project. Its a subproject of only one language in the Riffle libraries. You should be working out of the main [exis repo!](https:/github.com/exis-io/Exis)

Requirements 

- Install go, make sure gopath is set
- Install gomobile
- Install needed dependencies: `cd core && go get`
- use `stump.py init` to link the riffle core
- Run `make ios`
- Open `Example/Riffle.xcworkspace`, build, and run