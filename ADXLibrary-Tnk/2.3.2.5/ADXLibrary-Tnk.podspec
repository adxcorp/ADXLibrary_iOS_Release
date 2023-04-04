Pod::Spec.new do |s|
  s.name = "ADXLibrary-Tnk"
  s.version = '2.3.2.5'
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
                            'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
                            'ENABLE_BITCODE' => 'NO', 
                            'OTHER_LDFLAGS' => '-ObjC'
                          }
  s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '"${PODS_ROOT}/ADXLibrary-Tnk/ios/ADXLibrary_Tnk.framework/Frameworks"' }
  s.user_target_xcconfig = {'FRAMEWORK_SEARCH_PATHS' => '"${PODS_ROOT}/ADXLibrary-Tnk/ios/ADXLibrary_Tnk.framework/Frameworks"'}  
  s.vendored_frameworks = 'ios/ADXLibrary_Tnk.framework'

end
