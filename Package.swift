// swift-tools-version:5.7
import PackageDescription

// MARK: - Target Name

private struct TargetName {
    static let coreSupport = "ADXLibraryCoreSupport"
    static let adMobSupport = "ADXLibraryAdMobSupport"
    static let adPieSupport = "ADXLibraryAdPieSupport"
    static let adPieXSupport = "ADXLibraryAdPieXSupport"
    static let appLovinSupport = "ADXLibraryAppLovinSupport"
    static let bidMachineSupport = "ADXLibraryBidMachineSupport"
    static let caulySupport = "ADXLibraryCaulySupport"
    static let domainSupport = "ADXLibraryDomainSupport"
    static let fbAudienceNetworkSupport = "ADXLibraryFBAudienceNetworkSupport"
    static let liftOffSupport = "ADXLibraryLiftOffSupport"
    static let mintegralSupport = "ADXLibraryMintegralSupport"
    static let pangleSupport = "ADXLibraryPangleSupport"
    static let yandexSupport = "ADXLibraryYandexSupport"
    static let fyberSupport = "ADXLibraryFyberSupport"
    static let inMobiSupport = "ADXLibraryInMobiSupport"
    static let molocoSupport = "ADXLibraryMolocoSupport"
    static let pubMaticSupport = "ADXLibraryPubMaticSupport"
    static let unityAdsSupport = "ADXLibraryUnityAdsSupport"
    static let nativeSupport = "ADXLibraryNativeSupport"
    static let standardSupport = "ADXLibraryStandardSupport"
    static let rewardedSupport = "ADXLibraryRewardedSupport"
    static let kadpSupport = "ADXLibraryKADPSupport"
}

// MARK: - Product Name

private struct ProductName {
    static let bidMachine = "ADXLibrary-BidMachine"
    static let cauly = "ADXLibrary-Cauly"
    static let liftOff = "ADXLibrary-LiftOff"
    static let yandex = "ADXLibrary-Yandex"
    static let inMobi = "ADXLibrary-InMobi"
    static let pubMatic = "ADXLibrary-PubMatic"
    static let standard = "ADXLibrary"
    static let native = "ADXLibrary-Native"
    static let rewarded = "ADXLibrary-Rewarded"
    static let kadp = "ADXLibrary-KADP"
}

// MARK: - Binary Target Name

private struct BinaryTargetName {
    static let core = "ADXLibraryCoreBinary"
    static let adMob = "ADXLibraryAdMobBinary"
    static let adPie = "ADXLibraryAdPieBinary"
    static let adPieX = "ADXLibraryAdPieXBinary"
    static let appLovin = "ADXLibraryAppLovinBinary"
    static let bidMachine = "ADXLibraryBidMachineBinary"
    static let cauly = "ADXLibraryCaulyBinary"
    static let caulySDK = "CaulySDKBinary"
    static let domain = "ADXLibraryDomainBinary"
    static let fbAudienceNetwork = "ADXLibraryFBAudienceNetworkBinary"
    static let liftOff = "ADXLibraryLiftOffBinary"
    static let mintegral = "ADXLibraryMintegralBinary"
    static let pangle = "ADXLibraryPangleBinary"
    static let yandex = "ADXLibraryYandexBinary"
    static let fyber = "ADXLibraryFyberBinary"
    static let inMobi = "ADXLibraryInMobiBinary"
    static let moloco = "ADXLibraryMolocoBinary"
    static let pubMatic = "ADXLibraryPubMaticBinary"
    static let unityAds = "ADXLibraryUnityAdsBinary"
}

// MARK: - Binary Asset

private struct BinaryAsset {
    static let core = "ios/ADXLibrary.xcframework"
    static let adMob = "ios/ADXLibrary_AdMob.xcframework"
    static let adPie = "ios/ADXLibrary_AdPie.xcframework"
    static let adPieX = "ios/ADXLibrary_KADP.xcframework"
    static let appLovin = "ios/ADXLibrary_AppLovin.xcframework"
    static let bidMachine = "ios/ADXLibrary_BidMachine.xcframework"
    static let cauly = "ios/ADXLibrary-Cauly.xcframework"
    static let caulySDK = "ios/CaulySDK.xcframework"
    static let domain = "ios/ADXLibrary_Domain.xcframework"
    static let fbAudienceNetwork = "ios/ADXLibrary-FBAudienceNetwork.xcframework"
    static let liftOff = "ios/ADXLibrary_LiftOff.xcframework"
    static let mintegral = "ios/ADXLibrary-Mintegral.xcframework"
    static let pangle = "ios/ADXLibrary-Pangle.xcframework"
    static let yandex = "ios/ADXLibrary_Yandex.xcframework"
    static let fyber = "ios/ADXLibrary-Fyber.xcframework"
    static let inMobi = "ios/ADXLibrary_InMobi.xcframework"
    static let moloco = "ios/ADXLibrary_Moloco.xcframework"
    static let pubMatic = "ios/ADXLibrary_PubMatic.xcframework"
    static let unityAds = "ios/ADXLibrary-UnityAds.xcframework"
}

// MARK: - Repository URL

private struct RepositoryURL {
    static let googleMobileAds = "https://github.com/googleads/swift-package-manager-google-mobile-ads.git"
    static let appLovin = "https://github.com/AppLovin/AppLovin-MAX-Swift-Package.git"
    static let adPie = "https://github.com/gomfactory/AdPie-iOS-SDK.git"
    static let adPieX = "https://github.com/adxcorp/adpiex-ios-sdk"
    static let bidMachine = "https://github.com/bidmachine/BidMachine-SPM.git"
    static let fbAudienceNetwork = "https://github.com/facebook/FBAudienceNetwork.git"
    static let vungleAds = "https://github.com/Vungle/VungleAdsSDK-SwiftPackageManager.git"
    static let mintegral = "https://github.com/Mintegral-official/MintegralAdSDK-Swift-Package.git"
    static let adsGlobal = "https://github.com/bytedance/AdsGlobalPackage.git"
    static let yandexMobileAds = "https://github.com/yandexmobile/yandex-ads-sdk-ios.git"
    static let moloco = "https://github.com/moloco/moloco-sdk-ios-spm.git"
    static let inMobi = "https://github.com/InMobi/InMobiSDK-Swift-Package.git"
    static let dtExchange = "https://github.com/inner-active/DTExchangeSDK-iOS-SPM.git"
    static let openWrap = "https://github.com/PubMatic/OpenWrapSDK-Swift-Package.git"
    static let unityAds = "https://github.com/Unity-Technologies/Unity-Ads-Swift-Package.git"
}

// MARK: - Dependency

private let googleMobileAds: Target.Dependency = .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads")
private let appLovin: Target.Dependency = .product(name: "AppLovinSDK", package: "AppLovin-MAX-Swift-Package")
private let adPie: Target.Dependency = .product(name: "spm-adpie-framework", package: "AdPie-iOS-SDK")
private let adPieX: Target.Dependency = .product(name: "spm-adpie-x-framework", package: "adpiex-ios-sdk")
private let bidMachine: Target.Dependency = .product(name: "BidMachine", package: "BidMachine-SPM")
private let fbAudienceNetwork: Target.Dependency = .product(name: "FBAudienceNetwork", package: "FBAudienceNetwork")
private let vungleAds: Target.Dependency = .product(name: "VungleAdsSDK", package: "VungleAdsSDK-SwiftPackageManager")
private let mintegralAdSDK: Target.Dependency = .product(name: "MintegralAdSDK", package: "MintegralAdSDK-Swift-Package")
private let adsGlobalPackage: Target.Dependency = .product(name: "AdsGlobalPackage", package: "AdsGlobalPackage")
private let yandexMobileAds: Target.Dependency = .product(name: "YandexMobileAds", package: "yandex-ads-sdk-ios")
private let molocoSDK: Target.Dependency = .product(name: "MolocoSDK", package: "moloco-sdk-ios-spm")
private let inMobiSDK: Target.Dependency = .product(name: "InMobiSDK", package: "InMobiSDK-Swift-Package")
private let dtExchangeSDK: Target.Dependency = .product(name: "DTExchangeSDK", package: "DTExchangeSDK-iOS-SPM")
private let openWrapSDK: Target.Dependency = .product(name: "OpenWrapSDK", package: "OpenWrapSDK-Swift-Package")
private let unityAds: Target.Dependency = .product(name: "UnityAds", package: "Unity-Ads-Swift-Package")

// MARK: - Support

private func targetDependency(_ name: String) -> Target.Dependency {
    .byName(name: name)
}

private func makeSupportTarget(
    name: String,
    dependencies: [Target.Dependency],
    path: String
) -> Target {
    .target(
        name: name,
        dependencies: dependencies,
        path: path
    )
}

private func makeBinaryTarget(
    name: String,
    path: String
) -> Target {
    .binaryTarget(name: name, path: path)
}

// MARK: - Package

let package = Package(
    name: "ADXLibrary",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: ProductName.standard, targets: [TargetName.standardSupport]),
        .library(name: ProductName.native, targets: [TargetName.nativeSupport]),
        .library(name: ProductName.rewarded, targets: [TargetName.rewardedSupport]),
        .library(name: ProductName.kadp, targets: [TargetName.kadpSupport]),
        .library(name: ProductName.cauly, targets: [TargetName.caulySupport]),
        .library(name: ProductName.bidMachine, targets: [TargetName.bidMachineSupport]),
        .library(name: ProductName.yandex, targets: [TargetName.yandexSupport]),
        .library(name: ProductName.inMobi, targets: [TargetName.inMobiSupport]),
        .library(name: ProductName.pubMatic, targets: [TargetName.pubMaticSupport]),
    ],
    dependencies: [
        .package(url: RepositoryURL.googleMobileAds, exact: "13.6.0"),
        .package(url: RepositoryURL.appLovin, exact: "13.6.3"),
        .package(url: RepositoryURL.adPie, exact: "1.7.1"),
        .package(url: RepositoryURL.adPieX, exact: "1.0.6"),
        .package(url: RepositoryURL.bidMachine, exact: "3.7.1"),
        .package(url: RepositoryURL.fbAudienceNetwork, exact: "6.21.1"),
        .package(url: RepositoryURL.vungleAds, exact: "7.7.6"),
        .package(url: RepositoryURL.mintegral, exact: "8.1.5"),
        .package(url: RepositoryURL.adsGlobal, exact: "8.2.0-release.9"),
        .package(url: RepositoryURL.yandexMobileAds, exact: "8.2.0"),
        .package(url: RepositoryURL.moloco, exact: "4.9.0"),
        .package(url: RepositoryURL.inMobi, exact: "11.3.0"),
        .package(url: RepositoryURL.dtExchange, exact: "8.4.7"),
        .package(url: RepositoryURL.openWrap, exact: "5.2.0"),
        .package(url: RepositoryURL.unityAds, exact: "4.19.0")
    ],
    targets: [
        makeSupportTarget(
            name: TargetName.coreSupport,
            dependencies: [targetDependency(BinaryTargetName.core)],
            path: "Sources/ADXLibrarySPMSupport"
        ),
        makeSupportTarget(
            name: TargetName.adMobSupport,
            dependencies: [
                targetDependency(BinaryTargetName.adMob), targetDependency(TargetName.coreSupport),
                googleMobileAds, appLovin
            ],
            path: "Sources/ADXLibraryAdMobSPMSupport"
        ),
        makeSupportTarget(
            name: TargetName.adPieSupport,
            dependencies: [
              targetDependency(BinaryTargetName.adPie), targetDependency(TargetName.coreSupport),
              googleMobileAds, appLovin, adPie
            ],
            path: "Sources/ADXLibraryAdPieSPMSupport"
        ),
        makeSupportTarget(
            name: TargetName.adPieXSupport,
            dependencies: [
              targetDependency(BinaryTargetName.adPieX), targetDependency(TargetName.coreSupport),
              googleMobileAds, appLovin, adPieX
            ],
            path: "Sources/ADXLibraryAdPieXSPMSupport"
        ),
        makeSupportTarget(
            name: TargetName.appLovinSupport,
            dependencies: [
              targetDependency(BinaryTargetName.appLovin), targetDependency(TargetName.coreSupport),
              googleMobileAds, appLovin
            ],
            path: "Sources/ADXLibraryAppLovinSPMSupport"
        ),
        makeSupportTarget(
            name: TargetName.bidMachineSupport,
            dependencies: [
              targetDependency(BinaryTargetName.bidMachine), targetDependency(TargetName.coreSupport),
              appLovin, bidMachine
            ],
            path: "Sources/ADXLibraryBidMachineSPMSupport"
        ),
        makeSupportTarget(
            name: TargetName.caulySupport,
            dependencies: [
              targetDependency(BinaryTargetName.cauly), targetDependency(BinaryTargetName.caulySDK),
              targetDependency(TargetName.coreSupport), appLovin
            ],
            path: "Sources/ADXLibraryCaulySPMSupport"
        ),
        makeSupportTarget(
            name: TargetName.domainSupport,
            dependencies: [targetDependency(BinaryTargetName.domain)],
            path: "Sources/ADXLibraryDomainSPMSupport"
        ),
        makeSupportTarget(
            name: TargetName.fbAudienceNetworkSupport,
            dependencies: [
              targetDependency(BinaryTargetName.fbAudienceNetwork), targetDependency(TargetName.coreSupport),
              googleMobileAds, appLovin, fbAudienceNetwork
            ],
            path: "Sources/ADXLibraryFBAudienceNetworkSPMSupport"
        ),
        makeSupportTarget(
            name: TargetName.liftOffSupport,
            dependencies: [
              targetDependency(BinaryTargetName.liftOff), targetDependency(TargetName.coreSupport),
              appLovin, vungleAds
            ],
            path: "Sources/ADXLibraryLiftOffSPMSupport"
        ),
        makeSupportTarget(
            name: TargetName.mintegralSupport,
            dependencies: [
              targetDependency(BinaryTargetName.mintegral), targetDependency(TargetName.coreSupport),
              appLovin, mintegralAdSDK
            ],
            path: "Sources/ADXLibraryMintegralSPMSupport"
        ),
        makeSupportTarget(
            name: TargetName.pangleSupport,
            dependencies: [
              targetDependency(BinaryTargetName.pangle), targetDependency(TargetName.coreSupport),
              googleMobileAds, appLovin, adsGlobalPackage
            ],
            path: "Sources/ADXLibraryPangleSPMSupport"
        ),
        makeSupportTarget(
            name: TargetName.yandexSupport,
            dependencies: [
              targetDependency(BinaryTargetName.yandex), targetDependency(TargetName.coreSupport),
              appLovin, yandexMobileAds
            ],
            path: "Sources/ADXLibraryYandexSPMSupport"
        ),
        makeSupportTarget(
            name: TargetName.fyberSupport,
            dependencies: [
              targetDependency(BinaryTargetName.fyber), targetDependency(TargetName.coreSupport),
              googleMobileAds, appLovin, dtExchangeSDK
            ],
            path: "Sources/ADXLibraryFyberSPMSupport"
        ),
        makeSupportTarget(
            name: TargetName.inMobiSupport,
            dependencies: [
              targetDependency(BinaryTargetName.inMobi), targetDependency(TargetName.coreSupport),
              appLovin, inMobiSDK
            ],
            path: "Sources/ADXLibraryInMobiSPMSupport"
        ),
        makeSupportTarget(
            name: TargetName.molocoSupport,
            dependencies: [
              targetDependency(BinaryTargetName.moloco), targetDependency(TargetName.coreSupport),
              appLovin, molocoSDK
            ],
            path: "Sources/ADXLibraryMolocoSPMSupport"
        ),
        makeSupportTarget(
            name: TargetName.pubMaticSupport,
            dependencies: [
              targetDependency(BinaryTargetName.pubMatic), targetDependency(TargetName.coreSupport),
              appLovin, openWrapSDK]
            ,
            path: "Sources/ADXLibraryPubMaticSPMSupport"
        ),
        makeSupportTarget(
            name: TargetName.unityAdsSupport,
            dependencies: [
              targetDependency(BinaryTargetName.unityAds), targetDependency(TargetName.coreSupport),
              googleMobileAds, appLovin, unityAds
            ],
            path: "Sources/ADXLibraryUnityAdsSPMSupport"
        ),

        makeSupportTarget(
            name: TargetName.nativeSupport,
            dependencies: [
              targetDependency(TargetName.coreSupport), targetDependency(TargetName.adPieSupport),
              targetDependency(TargetName.adMobSupport), targetDependency(TargetName.appLovinSupport),
              targetDependency(TargetName.fbAudienceNetworkSupport), targetDependency(TargetName.molocoSupport),
              targetDependency(TargetName.fyberSupport), targetDependency(TargetName.pangleSupport),
              targetDependency(TargetName.mintegralSupport), targetDependency(TargetName.liftOffSupport)
            ],
            path: "Sources/ADXLibraryNativeSPMSupport"
        ),
        makeSupportTarget(
            name: TargetName.standardSupport,
            dependencies: [targetDependency(TargetName.nativeSupport), targetDependency(TargetName.unityAdsSupport)],
            path: "Sources/ADXLibraryStandardSPMSupport"
        ),
        makeSupportTarget(
            name: TargetName.rewardedSupport,
            dependencies: [targetDependency(TargetName.standardSupport)],
            path: "Sources/ADXLibraryRewardedSPMSupport"
        ),
        makeSupportTarget(
            name: TargetName.kadpSupport,
            dependencies: [
              targetDependency(TargetName.coreSupport), targetDependency(TargetName.domainSupport),
              targetDependency(TargetName.adPieXSupport), targetDependency(TargetName.adMobSupport),
              targetDependency(TargetName.appLovinSupport), targetDependency(TargetName.fbAudienceNetworkSupport),
              targetDependency(TargetName.unityAdsSupport), targetDependency(TargetName.fyberSupport),
              targetDependency(TargetName.molocoSupport), targetDependency(TargetName.inMobiSupport),
              targetDependency(TargetName.liftOffSupport)
            ],
            path: "Sources/ADXLibraryLiteSPMSupport"
        ),
        makeBinaryTarget(name: BinaryTargetName.core, path: BinaryAsset.core),
        makeBinaryTarget(name: BinaryTargetName.adMob, path: BinaryAsset.adMob),
        makeBinaryTarget(name: BinaryTargetName.adPie, path: BinaryAsset.adPie),
        makeBinaryTarget(name: BinaryTargetName.adPieX, path: BinaryAsset.adPieX),
        makeBinaryTarget(name: BinaryTargetName.appLovin, path: BinaryAsset.appLovin),
        makeBinaryTarget(name: BinaryTargetName.bidMachine, path: BinaryAsset.bidMachine),
        makeBinaryTarget(name: BinaryTargetName.cauly, path: BinaryAsset.cauly),
        makeBinaryTarget(name: BinaryTargetName.caulySDK, path: BinaryAsset.caulySDK),
        makeBinaryTarget(name: BinaryTargetName.domain, path: BinaryAsset.domain),
        makeBinaryTarget(name: BinaryTargetName.fbAudienceNetwork, path: BinaryAsset.fbAudienceNetwork),
        makeBinaryTarget(name: BinaryTargetName.liftOff, path: BinaryAsset.liftOff),
        makeBinaryTarget(name: BinaryTargetName.mintegral, path: BinaryAsset.mintegral),
        makeBinaryTarget(name: BinaryTargetName.pangle, path: BinaryAsset.pangle),
        makeBinaryTarget(name: BinaryTargetName.yandex, path: BinaryAsset.yandex),
        makeBinaryTarget(name: BinaryTargetName.fyber, path: BinaryAsset.fyber),
        makeBinaryTarget(name: BinaryTargetName.inMobi, path: BinaryAsset.inMobi),
        makeBinaryTarget(name: BinaryTargetName.moloco, path: BinaryAsset.moloco),
        makeBinaryTarget(name: BinaryTargetName.pubMatic, path: BinaryAsset.pubMatic),
        makeBinaryTarget(name: BinaryTargetName.unityAds, path: BinaryAsset.unityAds),
    ]
)
