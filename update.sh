pod repo push ADXLibrary ADXLibrary-Cauly.podspec --allow-warnings --verbose --skip-import-validation --use-libraries
pod repo push ADXLibrary ADXLibrary-FBAudienceNetwork.podspec --allow-warnings --verbose --skip-import-validation --use-libraries
pod repo push ADXLibrary ADXLibrary-Fyber.podspec --allow-warnings --verbose --skip-import-validation --use-libraries
pod repo push ADXLibrary ADXLibrary-Mintegral.podspec --allow-warnings --verbose --skip-import-validation --use-libraries
pod repo push ADXLibrary ADXLibrary-Pangle.podspec --allow-warnings --verbose --skip-import-validation --use-libraries
pod repo push ADXLibrary ADXLibrary-Tapjoy.podspec --allow-warnings --verbose --skip-import-validation --use-libraries
pod repo push ADXLibrary ADXLibrary-UnityAds.podspec --allow-warnings --verbose --skip-import-validation --use-libraries
pod repo update
pod spec lint ADXLibrary.podspec --sources='https://github.com/adxcorp/ADXLibrary_iOS_Release.git, https://github.com/CocoaPods/Specs.git'  --allow-warnings --verbose --skip-import-validation --use-libraries
pod repo push ADXLibrary ADXLibrary.podspec --allow-warnings --verbose --skip-import-validation --use-libraries
