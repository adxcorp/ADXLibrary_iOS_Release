Pod::Spec.new do |s|
  s.name = "ADXLibrary-AdColony"
  s.version = "1.5.20"
  s.summary = "ADX Library for iOS"
  s.license = {"type"=>"MIT", "file"=>"LICENSE"}
  s.authors = {"Chiung Choi"=>"god@adxcorp.kr"}
  s.homepage = "https://github.com/adxcorp/AdxLibrary_iOS"
  s.description = "ADX Library for iOS"
  s.source = { :git => 'https://adx-developer:developer2017@github.com/adxcorp/AdxLibrary_iOS_Release.git', :tag => s.version.to_s }
  s.ios.deployment_target    = '9.0'

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

  s.ios.vendored_framework   =  'ios/ADXLibrary-AdColony.framework'
  
  s.dependency 'mopub-ios-sdk', '5.4.1'
  s.dependency 'Google-Mobile-Ads-SDK', '7.47.0'
  s.dependency 'AdColony', '3.3.8.1'

  s.library       = 'z', 'sqlite3', 'xml2', 'c++'

  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO', 'OTHER_LDFLAGS' => '-ObjC'}
end
