#
# Be sure to run `pod lib lint Riffle.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = "Riffle"
    s.version          = "0.1.3"
    s.summary          = "Client side library for connecting to a fabric."

    s.ios.deployment_target = "8.0"
    s.osx.deployment_target = "10.10"

    s.description      = <<-DESC
Riffle allows for simple interaction with a Fabric. This library is meant to replace your
networking code with something that doesn't look like networking code at all!
                       DESC

    s.homepage         = "https://github.com/exis-io/swiftRiffle"
    s.license          = 'MIT'
    s.author           = { "Mickey Barboi" => "damouse007@gmail.com" }
    s.source           = { :git => "https://github.com/exis-io/swiftRiffle.git", :tag => s.version.to_s }

    s.requires_arc = true

    s.source_files = 'Pod/Classes/**/*'

    s.dependency 'SocketRocket', '0.4.1'
    s.dependency 'MPMessagePack', '1.3.2'
    s.dependency 'CocoaAsyncSocket', '7.4.1'
    s.dependency 'Mantle', '1.5'


end
