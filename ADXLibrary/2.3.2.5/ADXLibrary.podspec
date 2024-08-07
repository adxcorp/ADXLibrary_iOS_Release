Pod::Spec.new do |s|
  s.name = 'ADXLibrary'
  s.version = '2.3.2.5'
  s.summary = 'ADXLibrary for iOS'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.authors = { 'Chiung Choi' => 'god@adxcorp.kr' }
  s.homepage = 'https://www.adxcorp.kr/'
  s.description = 'ADXLibrary for iOS'
  s.source = { :git => 'https://github.com/adxcorp/AdxLibrary_iOS_Release.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'
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
                            'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
                            'ENABLE_BITCODE' => 'NO', 
                            'OTHER_LDFLAGS' => '-ObjC'
                          }

  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  s.default_subspecs = 'ADXSdk'

  s.subspec 'ADXSdk' do |sdk|
    sdk.dependency 'ADXLibrary/Base'
    sdk.dependency 'ADXLibrary/Standard'
    sdk.dependency 'ADXLibrary/Native'
    sdk.dependency 'ADXLibrary/Rewarded'
  end

  s.subspec 'Core' do |core|
    core.dependency 'Google-Mobile-Ads-SDK', '9.14.0'
    core.dependency 'AppLovinSDK', '11.6.1'
    core.dependency 'AdPieSDK', '1.4.6'
    core.vendored_frameworks = 'ios/ADXLibrary.framework'
  end

  s.subspec 'Base' do |base|
    base.dependency 'ADXLibrary/Core'
    base.dependency 'ADXLibrary-FBAudienceNetwork', '2.3.2.5'
    base.dependency 'ADXLibrary-Fyber', '2.3.2.5'
  end

  s.subspec 'Standard' do |standard|
    standard.dependency 'ADXLibrary/Base'
    standard.dependency 'ADXLibrary-Pangle', '2.3.2.5'
    standard.dependency 'ADXLibrary-UnityAds', '2.3.2.5'
    standard.dependency 'ADXLibrary-Mintegral', '2.3.2.5'
    standard.dependency 'ADXLibrary-Tnk', '2.3.2.5'
  end

  s.subspec 'Native' do |native|
    native.dependency 'ADXLibrary/Core'
    native.dependency 'ADXLibrary-FBAudienceNetwork', '2.3.2.5'
    native.dependency 'ADXLibrary-Pangle', '2.3.2.5'
    native.dependency 'ADXLibrary-Mintegral', '2.3.2.5'
    native.dependency 'ADXLibrary-Tnk', '2.3.2.5'
  end

  s.subspec 'Rewarded' do |rewarded|
    rewarded.dependency 'ADXLibrary/Base'
    rewarded.dependency 'ADXLibrary-Pangle', '2.3.2.5'
    rewarded.dependency 'ADXLibrary-UnityAds', '2.3.2.5'
    rewarded.dependency 'ADXLibrary-Mintegral', '2.3.2.5'
    rewarded.dependency 'ADXLibrary-Tnk', '2.3.2.5'
  end

end
