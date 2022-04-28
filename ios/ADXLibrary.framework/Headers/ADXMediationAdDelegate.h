//
//  ADXMediationAdDelegate.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADXNativeAd.h"
#import "ADXReward.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ADXMediationAdDelegate <NSObject>

@optional
- (void)didFailToLoadAdWithError:(NSError *)error;
- (void)didClickAd;

@end

@protocol ADXMediationBannerAdDelegate <ADXMediationAdDelegate>

- (void)didLoadAdView:(UIView *)adVoew;

@end

@protocol ADXMediationInterstitialAdDelegate <ADXMediationAdDelegate>

@optional
- (void)didLoadAd;
- (void)didFailToShowAdWithError:(NSError *)error;
- (void)willPresentScreen;
- (void)willDismissScreen;
- (void)didDismissScreen;

@end

@protocol ADXMediationNativeAdDelegate <ADXMediationAdDelegate>

@optional
- (void)didLoadAd;
- (void)trackImpression;

@end

@protocol ADXMediationRewardedAdDelegate <ADXMediationAdDelegate>

@optional
- (void)didLoadAd;
- (void)didFailToShowAdWithError:(NSError *)error;
- (void)willPresentScreen;
- (void)willDismissScreen;
- (void)didDismissScreen;

- (void)didRewardUserWithReward:(ADXReward *)reward;

- (void)didStartVideo;
- (void)didEndVideo;

@end

NS_ASSUME_NONNULL_END
