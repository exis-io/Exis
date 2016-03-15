

Pod::Spec.new do |s|


s.name             = "Riffle"
s.version          = "0.2.10"
s.summary          = "Client side library for connecting to a fabric."

s.description      = <<-DESC
Riffle allows for simple interaction with a Fabric, made by Exis. This library is meant to replace your
networking code with something that doesn't look like networking code at all!
DESC

s.homepage         = "https://github.com/exis-io/swiftRiffle"
s.license          = 'MIT'
s.author           = { "Damouse" => "damouse007@gmail.com" }
s.requires_arc = true

s.ios.deployment_target = "8.0"
s.osx.deployment_target = "10.11"


# Options for github distribution. Note that the "true" repo remaps the name of this repo
s.source = { :git => "https://github.com/exis-io/swiftRiffleCocoapod.git", :tag => s.version.to_s }
s.source_files = 'Pod/Classes/**/*.swift'
s.ios.vendored_frameworks = "Pod/Assets/ios/Mantle.framework"
s.osx.vendored_frameworks = "Pod/Assets/osx/Mantle.framework"


# Options for aws. If cocoapod can build successfully then this can be used
# See here: 
#s.ios.source = { :http => "http://riffle-dist.s3-website-us-west-2.amazonaws.com/swiftRiffle.zip" }

#s.source_files = 'swiftRiffle/Pod/Classes/**/*.swift'

#s.ios.vendored_frameworks = "swiftRiffle/Pod/Assets/ios/Mantle.framework"
#s.ios.preserve_paths = "swiftRiffle/Pod/Assets/ios/Mantle.framework/Versions/A/Mantle"

#s.osx.vendored_frameworks = "Pod/Assets/osx/Mantle.framework"
#s.osx.preserve_paths = "Pod/Assets/osx/Mantle.framework/Versions/A/Mantle"

#s.osx.xcconfig = { "EMBEDDED_CONTENT_CONTAINS_SWIFT" => "YES", "LD_RUNPATH_SEARCH_PATHS" => "$(inherited) @executable_path/Riffle-OSX"}


end

