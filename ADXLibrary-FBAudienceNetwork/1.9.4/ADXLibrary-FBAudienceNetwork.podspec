Pod::Spec.new do |s|
  s.name = "ADXLibrary-FBAudienceNetwork"
  s.version = "1.9.4"
  s.summary = "ADX Library for iOS"
  s.license = {"type"=>"MIT", "file"=>"LICENSE"}
  s.authors = {"Chiung Choi"=>"god@adxcorp.kr"}
  s.homepage = "https://github.com/adxcorp/AdxLibrary_iOS"
  s.description = "ADX Library for iOS"
  s.source = { :git => 'https://github.com/adxcorp/AdxLibrary_iOS_Release.git', :tag => s.version.to_s }
  s.ios.deployment_target    = '10.0'
  
  s.frameworks =    'Accelerate',
                    'AdSupport',
                    'AudioToolbox',
                    'AVFoundation',
                    'CFNetwork',
                    'CoreGraphics',
                    'CoreMotion',
                    'CoreMedia',
                    'CoreTelephony',
                    'Foundation',
                    'GLKit',
                    'MobileCoreServices',
                    'MediaPlayer',
                    'QuartzCore',
                    'StoreKit',
                    'SystemConfiguration',
                    'UIKit',
                    'VideoToolbox',
                    'WebKit'
                    
  s.ios.vendored_framework   =  'ios/ADXLibrary-FBAudienceNetwork.framework'
  
  s.dependency 'mopub-ios-sdk', '5.18.2'
  s.dependency 'Google-Mobile-Ads-SDK', '8.11.0'

  s.libraries = ["z", "sqlite3", "xml2", "c++"]
  
  s.default_subspec = 'Default'
  
  ### Begin: Subspecs
  
  s.subspec 'Default' do |ds|
  
  	ds.dependency 'FBAudienceNetwork','6.7.0'
  	
  end
  
  s.subspec 'Lib' do |ls|
  
  	ls.dependency 'ADXLibrary-FBAudienceNetwork/Lib-FBAudienceNetwork'
  	ls.dependency 'ADXLibrary-FBAudienceNetwork/Lib-FBSDKCoreKit_Basics'
  	
  end
  
  s.subspec 'Lib-FBAudienceNetwork' do |fas|
  
	fas.ios.vendored_framework =	'ios/ADXLibrary-FBAudienceNetwork.framework', 'ios/FBAudienceNetwork.xcframework'
	
  end
  
  s.subspec 'Lib-FBSDKCoreKit_Basics' do |fss|
  
  	fss.ios.vendored_framework = 'ios/FBSDKCoreKit_Basics.xcframework'
  	
  end
  
  ### End: Subspecs
  
  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO', 'OTHER_LDFLAGS' => '-ObjC', 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.xcconfig = { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES' }
end
