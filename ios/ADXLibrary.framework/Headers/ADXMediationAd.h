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

@optional
- (void)loadAdWithMediationData:(ADXMediationData *)mediation;

@end

@protocol ADXMediationBannerAd <ADXMediationAd>

@property (nonatomic, weak, nullable) id<ADXMediationBannerAdDelegate> delegate;

@optional

- (void)loadAdWithMediationData:(ADXMediationData *)mediation
                         adSize:(ADXAdSize)adSize
             rootViewControoler:(UIViewController *)rootViewController;

@end

@protocol ADXMediationInterstitialAd <ADXMediationAd>

@property (nonatomic, weak, nullable) id<ADXMediationInterstitialAdDelegate> delegate;

- (void)showAdFromRootViewController:(UIViewController *)rootViewController;

@end

@protocol ADXMediationNativeAd <ADXMediationAd>

@property (nonatomic, weak, nullable) id<ADXMediationNativeAdDelegate> delegate;

- (void)loadAdWithMediationData:(ADXMediationData *)mediation withRenderingViewClass:(Class)renderingViewClass;
- (UIView *)retrieveAdViewWithError:(NSError **)error;

@end

@protocol ADXMediationRewardedAd <ADXMediationAd>

@property (nonatomic, weak, nullable) id<ADXMediationRewardedAdDelegate> delegate;

- (void)showAdFromRootViewController:(UIViewController *)rootViewController;

@end

NS_ASSUME_NONNULL_END
