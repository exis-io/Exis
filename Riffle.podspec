#
# Be sure to run `pod lib lint Riffle.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Riffle"
  s.version          = "0.1.2"
  s.summary          = "Client side library for connecting to a fabric."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
Riffle allows for simple interaction with a Fabric. This library is meant to replace your
networking code with something that doesn't look like networking code at all!
                       DESC

    s.homepage         = "https://github.com/paradroplabs/riffle-swift"
    s.license          = 'MIT'
    s.author           = { "Mickey Barboi" => "damouse007@gmail.com" }
    s.source           = { :git => "https://github.com/paradroplabs/riffle-swift.git", :tag => s.version.to_s }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

    s.requires_arc = true

    s.source_files = 'Pod/Classes/**/*'
    s.resource_bundles = {
        'Riffle' => ['Pod/Assets/*.png']
    }

    s.dependency 'SocketRocket', '0.4.1'
    s.dependency 'MPMessagePack', '1.3.2'
    s.dependency 'CocoaAsyncSocket', '7.4.1'
    s.dependency 'Mantle', '1.5'
end
