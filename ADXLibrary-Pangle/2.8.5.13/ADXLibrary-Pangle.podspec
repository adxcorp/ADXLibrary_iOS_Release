Pod::Spec.new do |s|
  s.name = "ADXLibrary-Pangle"
  s.version = '2.8.5.13'
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
    standard.dependency 'Ads-Global', '7.9.0.8'

    standard.vendored_frameworks = 'ios/ADXLibrary-Pangle.xcframework'
  end

  s.subspec 'ADX-Pangle' do |adx_pangle|
    adx_pangle.dependency 'ADXLibrary-Core', s.version.to_s
    adx_pangle.dependency 'Ads-Global', '~> 7.4'

    adx_pangle.source_files = 
      'ios/adapters/MediationAdapter-Pangle/PangleAdapter/ADX/**/*.{h,m}'
    adx_pangle.public_header_files =
      'ios/adapters/MediationAdapter-Pangle/PangleAdapter/ADX/**/*.h'
  end
  
end
