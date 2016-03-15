

Pod::Spec.new do |s|


s.name             = "Riffle"
s.version          = "0.2.07"
s.summary          = "Client side library for connecting to a fabric."

s.ios.deployment_target = "8.0"
s.osx.deployment_target = "10.11"

s.description      = <<-DESC
Riffle allows for simple interaction with a Fabric, made by Exis. This library is meant to replace your
networking code with something that doesn't look like networking code at all!
DESC

s.homepage         = "https://github.com/exis-io/swiftRiffle"
s.license          = 'MIT'
s.author           = { "Damouse" => "damouse007@gmail.com" }
s.requires_arc = true


# Options for github distribution. Note that the "true" repo remaps the name of this repo
# s.source = { :git => "https://github.com/exis-io/swiftRiffle.git", :tag => s.version.to_s }
# s.source_files = 'Pod/Classes/**/*.swift'
# s.ios.vendored_frameworks = "Pod/Assets/ios/Mantle.framework"
# s.osx.vendored_frameworks = "Pod/Assets/osx/Mantle.framework"


# Options for aws. If cocoapod can build successfully then this can be used
s.source = { :http => "http://riffle-dist.s3-website-us-west-2.amazonaws.com/swiftRiffle.zip" }

s.source_files = 'Pod/Classes/**/*.swift'
s.ios.vendored_frameworks = "Pod/Assets/ios/Mantle.framework"
s.osx.vendored_frameworks = "Pod/Assets/osx/Mantle.framework"

s.osx.xcconfig = { "EMBEDDED_CONTENT_CONTAINS_SWIFT" => "YES", "LD_RUNPATH_SEARCH_PATHS" => "$(inherited) @executable_path/Riffle-OSX"}


end

