Pod::Spec.new do |s|
  s.name = 'ADXLibrary'
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

  s.subspec 'Core' do |core|
    core.dependency 'ADXLibrary-Core', s.version.to_s
  end

  # Standard와 동일하되 UnityAds만 빠진 구성
  s.subspec 'Native' do |native|
    native.dependency 'ADXLibrary/Core'
    native.dependency 'ADXLibrary-AdPie', s.version.to_s
    native.dependency 'ADXLibrary-AdMob', s.version.to_s
    native.dependency 'ADXLibrary-AppLovin', s.version.to_s
    native.dependency 'ADXLibrary-FBAudienceNetwork', s.version.to_s
    native.dependency 'ADXLibrary-Moloco', s.version.to_s
    native.dependency 'ADXLibrary-Tnk', s.version.to_s
    native.dependency 'ADXLibrary-Fyber', s.version.to_s
    native.dependency 'ADXLibrary-Pangle', s.version.to_s
    native.dependency 'ADXLibrary-Mintegral', s.version.to_s
  end

  # Native + UnityAds 구성 (전체 네트워크)
  s.subspec 'Standard' do |standard|
    standard.dependency 'ADXLibrary/Native'
    standard.dependency 'ADXLibrary-UnityAds', s.version.to_s
  end

  # Standard와 동일한 구성
  s.subspec 'Rewarded' do |rewarded|
    rewarded.dependency 'ADXLibrary/Standard'
  end

  # Core + Domain + AdMob + AdPie + UnityAds + FBAudienceNetwork만 포함하는 경량 구성
  s.subspec 'Lite' do |lite|
    lite.dependency 'ADXLibrary/Core'
    lite.dependency 'ADXLibrary-Domain', s.version.to_s
    lite.dependency 'ADXLibrary-AdPie', s.version.to_s
    lite.dependency 'ADXLibrary-AdMob', s.version.to_s
    lite.dependency 'ADXLibrary-AppLovin', s.version.to_s
    lite.dependency 'ADXLibrary-FBAudienceNetwork', s.version.to_s
    lite.dependency 'ADXLibrary-UnityAds', s.version.to_s
  end

  # ADX 자체 adapter만 모은 구성 (서드파티 adapter 제외)
  s.subspec 'ADXAdapters' do |adx_adapters|
    adx_adapters.dependency 'ADXLibrary/Core'
    adx_adapters.dependency 'ADXLibrary-AdPie/ADX-AdPie', s.version.to_s
    adx_adapters.dependency 'ADXLibrary-AdMob/ADX-GoogleAds', s.version.to_s
    adx_adapters.dependency 'ADXLibrary-AppLovin/ADX-AppLovin', s.version.to_s
    adx_adapters.dependency 'ADXLibrary-Fyber/ADX-Fyber', s.version.to_s
    adx_adapters.dependency 'ADXLibrary-Pangle/ADX-Pangle', s.version.to_s
    adx_adapters.dependency 'ADXLibrary-UnityAds/ADX-UnityAds', s.version.to_s
  end

end
