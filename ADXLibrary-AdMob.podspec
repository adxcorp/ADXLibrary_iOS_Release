Pod::Spec.new do |s|
  s.name = "ADXLibrary-AdMob"
  s.version = '2.8.5.11'
  s.summary = 'ADXLibrary for iOS'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.authors = { 'Chiung Choi' => 'god@adxcorp.kr' }
  s.homepage = 'https://www.adxcorp.kr/'
  s.description = 'ADXLibrary for iOS'
  s.source = { :git => 'https://github.com/adxcorp/AdxLibrary_iOS_Release.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.static_framework = true
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

  s.pod_target_xcconfig = { 
    'ENABLE_BITCODE' => 'NO', 
    'OTHER_LDFLAGS' => '-ObjC'
  }

  s.default_subspecs = 'Standard'

  s.subspec 'Standard' do |standard|
    standard.dependency 'ADXLibrary-Core', s.version.to_s
    standard.dependency 'Google-Mobile-Ads-SDK', '12.14.0'
    standard.dependency 'AppLovinSDK', '13.5.1'

    standard.vendored_frameworks = 'ios/ADXLibrary_AdMob.xcframework'
  end

  s.subspec 'ADX-GoogleAds' do |adapter|
    adapter.dependency 'ADXLibrary-Core', s.version.to_s
    adapter.dependency 'Google-Mobile-Ads-SDK', '~> 12.0'

    adapter.source_files = [
      'ios/adapters/MediationAdapter-AdMob/AdManagerAdapter/ADX/**/*.{h,m}',
      'ios/adapters/MediationAdapter-AdMob/AdMobAdapter/ADX/**/*.{h,m}'
    ]
    adapter.public_header_files = [
      'ios/adapters/MediationAdapter-AdMob/AdManagerAdapter/ADX/**/*.h',
      'ios/adapters/MediationAdapter-AdMob/AdMobAdapter/ADX/**/*.h'
    ]
  end

end