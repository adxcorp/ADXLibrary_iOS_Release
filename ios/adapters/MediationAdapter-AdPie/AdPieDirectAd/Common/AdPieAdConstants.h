//
//  AdPieAdConstants.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

typedef NS_ENUM(NSInteger, AdPieAdContentType) {
    AdPieAdContentTypeBannerImage        = 11,
    AdPieAdContentTypeInterstitalImage   = 21,
    AdPieAdContentTypeInterstitialIVideo = 22,
    AdPieAdContentTypeNativeImage        = 31,
    AdPieAdContentTypeNativeVideo        = 32,
    AdPieAdContentTypePrerollVideo       = 42,
    AdPieAdContentTypeRewardedVideo      = 52
};

typedef NS_ENUM(NSInteger, AdPieAdNativeAssetType) {
    AdPieAdNativeAssetTypeTitle          = 1,
    AdPieAdNativeAssetTypeIcon           = 2,
    AdPieAdNativeAssetTypeMain           = 3,
    AdPieAdNativeAssetTypeDesc           = 4,
    AdPieAdNativeAssetTypeRating         = 5,
    AdPieAdNativeAssetTypeCta            = 6
};

typedef NS_ENUM(NSInteger, AdPieAdOrientation) {
    AdPieAdOrientationNone               = 0,
    AdPieAdOrientationPortrait           = 1,
    AdPieAdOrientationLandscape          = 2
};

