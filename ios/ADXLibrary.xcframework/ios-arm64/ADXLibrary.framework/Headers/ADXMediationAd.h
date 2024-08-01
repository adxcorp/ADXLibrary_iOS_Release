//
//  ADXMediationAd.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ADXMediationAdDelegate.h"
#import "ADXMediationData.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ADXAdFormatType){
    ADX_AD_FORMAT_BANNER,
    ADX_AD_FORMAT_NATIVE,
    ADX_AD_FORMAT_REWARDED,
    ADXADX_AD_FORMAT_INTERSTITIAL,
    ADXADX_AD_FORMAT_UNKNOWN,
};


@protocol ADXMediationAd <NSObject>

@property (assign, readonly) BOOL isLoaded;

@end

@protocol ADXMediationBannerAd <ADXMediationAd>

@property (weak, nullable) id<ADXMediationBannerAdDelegate> delegate;

- (void)loadAdWithMediationData:(ADXMediationData *)mediation
                         adSize:(ADXAdSize)adSize
             rootViewControoler:(UIViewController *)rootViewController;

@end

@protocol ADXMediationNativeAd <ADXMediationAd>

@property (weak, nullable) id<ADXMediationNativeAdDelegate> delegate;

- (void)loadAdWithMediationData:(ADXMediationData *)mediation
             renderingViewClass:(Class)renderingViewClass
             rootViewController:(UIViewController *)rootViewController;

- (UIView *)retrieveAdViewWithError:(NSError **)error;

@end

@protocol ADXMediationInterstitialAd <ADXMediationAd>

@property (weak, nullable) id<ADXMediationInterstitialAdDelegate> delegate;

- (void)loadAdWithMediationData:(ADXMediationData *)mediation;
- (void)showAdFromRootViewController:(UIViewController *)rootViewController;

@end

@protocol ADXMediationRewardedAd <ADXMediationAd>

@property (weak, nullable) id<ADXMediationRewardedAdDelegate> delegate;

- (void)loadAdWithMediationData:(ADXMediationData *)mediation;
- (void)showAdFromRootViewController:(UIViewController *)rootViewController;

@end

NS_ASSUME_NONNULL_END
