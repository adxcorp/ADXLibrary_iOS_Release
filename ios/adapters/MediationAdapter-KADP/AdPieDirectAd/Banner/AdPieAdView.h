//
//  AdPieAdView.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AdPieAdData;
@protocol AdPieAdViewDelegate;

@interface AdPieAdView : UIView

@property (weak, nullable) UIViewController *rootViewController;
@property (weak, nullable) id<AdPieAdViewDelegate> delegate;

- (void)loadAdWithData:(AdPieAdData *)adData;

@end

@protocol AdPieAdViewDelegate <NSObject>

- (void)adViewDidLoad:(AdPieAdView *)adView;
- (void)adView:(AdPieAdView *)adView didFailToLoadWithError:(NSError *)error;
- (void)adViewDidClick:(AdPieAdView *)adView;

@end

NS_ASSUME_NONNULL_END

