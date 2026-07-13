//
//  ADXNativeInterstitialAdViewController.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ADXNativeInterstitialAdView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ADXNativeInterstitialAdViewControllerDelegate;

@interface ADXNativeInterstitialAdViewController : UIViewController

@property (weak, nullable) id<ADXNativeInterstitialAdViewControllerDelegate> delegate;
@property (strong, nullable) UIView *adContentView;

@end

@protocol ADXNativeInterstitialAdViewControllerDelegate <NSObject>

@optional

- (void)nativeInterstitialAdWillPresentScreen;
- (void)nativeInterstitialAdWillDismissScreen;
- (void)nativeInterstitialAdDidDismissScreen;

@end

NS_ASSUME_NONNULL_END
