platform :ios, '11.3'
inhibit_all_warnings!

target 'PIL' do

  source 'https://gitlab.linphone.org/BC/public/podspec.git'
  source 'https://github.com/CocoaPods/Specs.git'
  use_frameworks!

pod 'iOSPhoneLib', :git => 'https://gitlab.wearespindle.com/vialer/mobile/voip/ios-phone-lib.git'
  pod 'Swinject'

  target 'PILTests' do
    # Pods for testing
  end
  
  target 'PILExampleApp' do
    pod 'PIL', :path => '../PIL'
    pod 'AFNetworkActivityLogger'
    pod 'AFNetworking'
    pod 'SAMKeychain'
    pod 'QuickTableViewController'
    pod 'Alamofire', '~> 5.2'
  end

end
