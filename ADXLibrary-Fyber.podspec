Pod::Spec.new do |s|
  s.name = "ADXLibrary-Fyber"
  s.version = '2.8.5.15'
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
    standard.dependency 'Fyber_Marketplace_SDK', '8.4.5'

    s.vendored_frameworks = 'ios/ADXLibrary-Fyber.xcframework'
  end

  s.subspec 'ADX-Fyber' do |adx_fyber|
    adx_fyber.dependency 'ADXLibrary-Core', s.version.to_s
    adx_fyber.dependency 'Fyber_Marketplace_SDK', '~> 8.3'

    adx_fyber.source_files =
      'ios/adapters/MediationAdapter-Fyber/FyberAdapter/ADX/**/*.{h,m}'
    adx_fyber.public_header_files = 
      'ios/adapters/MediationAdapter-Fyber/FyberAdapter/ADX/**/*.h'
  end
  
end
