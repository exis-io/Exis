
Pod::Spec.new do |s|
    s.name             = "Riffle"
    s.version          = "0.1.71"
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
    s.source           = { :git => "https://github.com/exis-io/swiftRiffle.git", :tag => s.version.to_s }

    s.requires_arc = true
    s.source_files = 'Pod/Classes/**/*'

    s.ios.vendored_frameworks = "Pod/Assets/ios/Mantle.framework"
    s.ios.resource = "Pod/Assets/ios/Mantle.framework"
    s.ios.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '$(inherited) $(PODS_ROOT)/../../Pod/Assets/ios/' }

    s.osx.vendored_frameworks = "Pod/Assets/osx/Mantle.framework"
    s.osx.resource = "Pod/Assets/osx/Mantle.framework"
    s.osx.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '$(inherited) $(PODS_ROOT)/../../Pod/Assets/osx/'  }
end
