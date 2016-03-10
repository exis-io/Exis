<div align="center">
    <a href="http://slack.exis.io"><img src="http://slack.exis.io/badge.svg"></a>
    </h3>
</div>


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

