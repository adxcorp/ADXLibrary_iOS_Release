//
//  ADXInterstitialAd.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ADXInterstitialAdDelegate;

@interface ADXInterstitialAd : NSObject

@property (nonatomic, copy, readonly) NSString *adUnitId;
@property (nonatomic, weak, nullable) id<ADXInterstitialAdDelegate> delegate;
@property (nonatomic, assign, readonly, getter=isLoaded) BOOL loaded;

- (instancetype)initWithAdUnitId:(NSString *)adUnitId NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)decoder NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (void)loadAd;
- (void)showAdFromRootViewController:(UIViewController *)rootViewController;

@end

@protocol ADXInterstitialAdDelegate <NSObject>

@optional
- (void)interstitialAdDidLoad:(ADXInterstitialAd *)interstitialAd;
- (void)interstitialAd:(ADXInterstitialAd *)interstitialAd didFailToLoadWithError:(NSError *)error;
- (void)interstitialAd:(ADXInterstitialAd *)interstitialAd didFailToShowWithError:(NSError *)error;
- (void)interstitialAdWillPresentScreen:(ADXInterstitialAd *)interstitialAd;
- (void)interstitialAdWillDismissScreen:(ADXInterstitialAd *)interstitialAd;
- (void)interstitialAdDidDismissScreen:(ADXInterstitialAd *)interstitialAd;
- (void)interstitialAdDidClick:(ADXInterstitialAd *)interstitialAd;

@end

NS_ASSUME_NONNULL_END
