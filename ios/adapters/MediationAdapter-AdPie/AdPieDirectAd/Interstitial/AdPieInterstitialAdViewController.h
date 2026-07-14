//
//  AdPieInterstitialAdViewController.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AdPieAdData;
@protocol AdPieInterstitialAdViewControllerDelegate;

@interface AdPieInterstitialAdViewController : UIViewController

@property (weak, nullable) id<AdPieInterstitialAdViewControllerDelegate> delegate;

- (void)loadAdWithData:(AdPieAdData *)adData;

@end

@protocol AdPieInterstitialAdViewControllerDelegate <NSObject>

@optional
- (void)interstitialAdDidLoad;
- (void)interstitialAdDidFailToLoadWithError:(NSError *)error;
- (void)interstitialAdDidFailToShowWithError:(NSError *)error;
- (void)interstitialAdWillPresentScreen;
- (void)interstitialAdWillDismissScreen;
- (void)interstitialAdDidDismissScreen;
- (void)interstitialAdDidClick;

@end

NS_ASSUME_NONNULL_END
