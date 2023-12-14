Pod::Spec.new do |s|
  s.name = 'ADXLibrary'
  s.version = '2.5.2.3'
  s.summary = 'ADXLibrary for iOS'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.authors = { 'Chiung Choi' => 'god@adxcorp.kr' }
  s.homepage = 'https://www.adxcorp.kr/'
  s.description = 'ADXLibrary for iOS'
  s.source = { :git => 'https://github.com/adxcorp/AdxLibrary_iOS_Release.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
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

  s.default_subspecs = 'ADXSdk'

  s.subspec 'ADXSdk' do |sdk|
    sdk.dependency 'ADXLibrary/Base'
    sdk.dependency 'ADXLibrary/Standard'
    sdk.dependency 'ADXLibrary/Native'
    sdk.dependency 'ADXLibrary/Rewarded'
  end

  s.subspec 'Core' do |core|
    core.dependency 'Google-Mobile-Ads-SDK', '10.13.0'
    core.dependency 'AppLovinSDK', '12.0.0'
    core.dependency 'AdPieSDK', '1.5.8'
    core.dependency 'FBAudienceNetwork','6.14.0'
    core.vendored_frameworks = 'ios/ADXLibrary.xcframework', 'ios/TnkPubSdk.xcframework'
  end

  s.subspec 'Base' do |base|
    base.dependency 'ADXLibrary/Core'
    base.dependency 'ADXLibrary-FBAudienceNetwork', '2.5.2.3'
    base.dependency 'ADXLibrary-Fyber', '2.5.2.3'
  end

  s.subspec 'Base2' do |base2|
    base2.dependency 'ADXLibrary/Core'
    base2.dependency 'ADXLibrary-FBAudienceNetwork', '2.5.2.3'
  end

  s.subspec 'Standard' do |standard|
    standard.dependency 'ADXLibrary/Base'
    standard.dependency 'ADXLibrary-Pangle', '2.5.2.3'
    standard.dependency 'ADXLibrary-UnityAds', '2.5.2.3'
    standard.dependency 'ADXLibrary-Mintegral', '2.5.2.3'
  end

  s.subspec 'Native' do |native|
    native.dependency 'ADXLibrary/Core'
    native.dependency 'ADXLibrary-FBAudienceNetwork', '2.5.2.3'
    native.dependency 'ADXLibrary-Pangle', '2.5.2.3'
    native.dependency 'ADXLibrary-Mintegral', '2.5.2.3'
  end

  s.subspec 'Rewarded' do |rewarded|
    rewarded.dependency 'ADXLibrary/Base'
    rewarded.dependency 'ADXLibrary-Pangle', '2.5.2.3'
    rewarded.dependency 'ADXLibrary-UnityAds', '2.5.2.3'
    rewarded.dependency 'ADXLibrary-Mintegral', '2.5.2.3'
  end

  s.subspec 'UnityPlugin' do |unityplugin|
    unityplugin.dependency 'ADXLibrary/Base2'
    unityplugin.dependency 'ADXLibrary-Pangle', '2.5.2.3'
    unityplugin.dependency 'ADXLibrary-UnityAds', '2.5.2.3'
    unityplugin.dependency 'ADXLibrary-Mintegral', '2.5.2.3'
  end

end
