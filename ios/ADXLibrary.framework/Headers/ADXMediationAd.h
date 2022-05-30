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

@protocol ADXMediationAd <NSObject>

@property (nonatomic, assign, readonly) BOOL isLoaded;

@end

@protocol ADXMediationBannerAd <ADXMediationAd>

@property (nonatomic, weak, nullable) id<ADXMediationBannerAdDelegate> delegate;

- (void)loadAdWithMediationData:(ADXMediationData *)mediation
                         adSize:(ADXAdSize)adSize
             rootViewControoler:(UIViewController *)rootViewController;

@end

@protocol ADXMediationNativeAd <ADXMediationAd>

@property (nonatomic, weak, nullable) id<ADXMediationNativeAdDelegate> delegate;

- (void)loadAdWithMediationData:(ADXMediationData *)mediation
             renderingViewClass:(Class)renderingViewClass
             rootViewController:(UIViewController *)rootViewController;

- (UIView *)retrieveAdViewWithError:(NSError **)error;

@end

@protocol ADXMediationInterstitialAd <ADXMediationAd>

@property (nonatomic, weak, nullable) id<ADXMediationInterstitialAdDelegate> delegate;

- (void)loadAdWithMediationData:(ADXMediationData *)mediation;
- (void)showAdFromRootViewController:(UIViewController *)rootViewController;

@end

@protocol ADXMediationRewardedAd <ADXMediationAd>

@property (nonatomic, weak, nullable) id<ADXMediationRewardedAdDelegate> delegate;

- (void)loadAdWithMediationData:(ADXMediationData *)mediation;
- (void)showAdFromRootViewController:(UIViewController *)rootViewController;

@end

NS_ASSUME_NONNULL_END
