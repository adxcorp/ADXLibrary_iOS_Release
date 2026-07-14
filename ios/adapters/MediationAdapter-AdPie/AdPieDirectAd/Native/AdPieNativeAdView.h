//
//  AdPieNativeAdView.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AdPieNativeAdViewDelegate;

@interface AdPieNativeAdView : UIView

@property (weak) id nativeAd;
@property (weak, nullable) id<AdPieNativeAdViewDelegate> delegate;

- (void)registerClickableViews:(NSArray<UIView *> *)clickableViews;
- (void)registerClickablePrivacy:(UIView *)clickableView;

@end

@protocol AdPieNativeAdViewDelegate <NSObject>

@optional
- (void)nativeAdViewTrackImpression:(AdPieNativeAdView *)nativeAdView;
- (void)nativeAdViewDidClick:(AdPieNativeAdView *)nativeAdView;

@end

NS_ASSUME_NONNULL_END
