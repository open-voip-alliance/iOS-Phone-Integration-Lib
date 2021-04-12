platform :ios, '11.3'
inhibit_all_warnings!
use_frameworks!

target 'PIL' do
  source 'https://gitlab.linphone.org/BC/public/podspec.git'
  source 'https://github.com/CocoaPods/Specs.git'

  pod 'iOSVoIPLib', :git => 'https://gitlab.wearespindle.com/vialer/mobile/voip/ios-voip-lib.git'
  pod 'Swinject'
end

target 'PILTests' do
  # Pods for testing
end
  
target 'PILExampleApp' do
  pod 'PIL', :path => '.'
  pod 'SAMKeychain'
  pod 'QuickTableViewController'
  pod 'Alamofire', '~> 5.2'
end
