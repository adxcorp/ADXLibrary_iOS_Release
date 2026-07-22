Pod::Spec.new do |s|
  s.name = "ADXLibrary-AppLovin"
  s.version = '2.8.5.16'
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

    standard.vendored_frameworks = 'ios/ADXLibrary_AppLovin.xcframework'
  end

  s.subspec 'ADX-AppLovin' do |adx_applovin|
    adx_applovin.dependency 'ADXLibrary-Core', s.version.to_s
    adx_applovin.dependency 'AppLovinSDK', '~> 13.0'

    adx_applovin.source_files =
      'ios/adapters/MediationAdapter-AppLovin/AppLovinAdapter/ADX/**/*.{h,m}'
    adx_applovin.public_header_files = 
      'ios/adapters/MediationAdapter-AppLovin/AppLovinAdapter/ADX/**/*.h'
  end

end
