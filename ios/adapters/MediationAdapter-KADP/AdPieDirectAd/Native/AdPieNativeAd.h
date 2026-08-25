//
//  AdPieNativeAd.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AdPieNativeAdData;
@class AdPieNativeAdView;
@protocol AdPieNativeAdDelegate;

@interface AdPieNativeAd : NSObject

@property (weak, nullable) id<AdPieNativeAdDelegate> delegate;
@property (strong, readonly) AdPieNativeAdData *adData;

- (void)loadWithAdData:(AdPieNativeAdData *)adData;

- (void)fireImpression;
- (void)invokeDefaultAction;
- (void)invokePrivacyIconAction;

@end

@protocol AdPieNativeAdDelegate <NSObject>

@optional
- (void)nativeAdDidLoad:(AdPieNativeAd *)nativeAd;
- (void)nativeAd:(AdPieNativeAd *)nativeAd didFailToLoadWithError:(NSError *)error;
- (void)nativeAdDidClick:(AdPieNativeAd *)nativeAd;
- (void)nativeAdTrackImpression:(AdPieNativeAd *)nativeAd;

@end

NS_ASSUME_NONNULL_END
