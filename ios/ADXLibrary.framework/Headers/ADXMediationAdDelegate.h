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

@protocol ADXMediationAd;

@protocol ADXMediationAdDelegate <NSObject>

- (void)didFailAdWithError:(NSError *)error;

@optional
- (void)didClickAd;
- (void)trackImpression;
- (void)willPresentScreen;
- (void)willDismissScreen;
- (void)didDismissScreen;

@end

@protocol ADXMediationBannerAdDelegate <ADXMediationAdDelegate>

- (void)didLoadAdView:(UIView *)adVoew;

@optional
- (void)willBackgroundApplication;

@end

@protocol ADXMediationInterstitialAdDelegate <ADXMediationAdDelegate>

- (void)didLoadAd;

@optional
- (void)willBackgroundApplication;

@end

@protocol ADXMediationNativeAdDelegate <ADXMediationAdDelegate>

- (void)didLoadAd;

@end

@protocol ADXMediationRewardedAdDelegate <ADXMediationAdDelegate>

- (void)didLoadAd;

@optional
- (void)didStartVideo;
- (void)didEndVideo;
- (void)didRewardUserWithReward:(ADXReward *)reward;

@end

NS_ASSUME_NONNULL_END
