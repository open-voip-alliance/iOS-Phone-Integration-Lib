Pod::Spec.new do |s|

    s.platform = :ios
    s.ios.deployment_target = '11.3'
    s.name = "PIL"
    s.summary = "Platform integration layer uses Linphone through PhoneLib to provide SIP functionality."
    s.requires_arc = true

    s.version = "0.1.0"

    s.license = { :type => "MIT", :file => "LICENSE" }

    s.author = { "Chris Kontos" => "chris.kontos@wearespindle.com" }

    s.homepage = "https://gitlab.wearespindle.com/vialer/mobile/voip/platform-integration-layer"

    s.source = { :git => "https://gitlab.wearespindle.com/vialer/mobile/voip/platform-integration-layer.git",
                 :tag => "#{s.version}" }

    s.framework = "UIKit"
    s.dependency 'PhoneLib', '~> 0.1.0'

    s.source_files = "PIL/**/*.{swift}"

    s.resources = "PIL/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"

    s.swift_version = "5"

end