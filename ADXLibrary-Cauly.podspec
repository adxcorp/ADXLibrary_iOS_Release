Pod::Spec.new do |s|
  s.name = "ADXLibrary-Cauly"
  s.version = '2.3.5.1'
  s.summary = 'ADXLibrary for iOS'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.authors = { 'Chiung Choi' => 'god@adxcorp.kr' }
  s.homepage = 'https://www.adxcorp.kr/'
  s.description = 'ADXLibrary for iOS'
  s.source = { :git => 'https://github.com/adxcorp/AdxLibrary_iOS_Release.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.frameworks = [ 
                    'Accelerate',
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
                 ]

  s.libraries = 'z', 'sqlite3', 'xml2', 'c++'

  s.pod_target_xcconfig = { 
    'ENABLE_BITCODE' => 'NO', 
    'OTHER_LDFLAGS' => '-ObjC'
  }

  s.dependency 'Google-Mobile-Ads-SDK', '9.14.0'
  s.dependency 'AppLovinSDK', '11.6.1'
  
  s.vendored_frameworks = 'ios/ADXLibrary-Cauly.xcframework'

end
