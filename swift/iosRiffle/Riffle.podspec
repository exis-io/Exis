
Pod::Spec.new do |s|
    s.name             = "Riffle"
    s.version          = "0.1.70"
    s.summary          = "Client side library for connecting to a fabric."

    s.ios.deployment_target = "8.0"

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
    s.vendored_frameworks = "Pod/Assets/Mantle.framework"
end
