//
//  AdPieAdContentView.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdPieAdData.h"
#import "AdPieAdWebView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AdPieAdContentViewDelegate;

@interface AdPieAdContentView : UIView

@property (weak, nullable) id<AdPieAdContentViewDelegate> delegate;

- (void)setBannerAdData:(AdPieAdData *)adData delegate:(id<AdPieAdContentViewDelegate>)delegate;
- (void)setInterstitialAdData:(AdPieAdData *)adData delegate:(id<AdPieAdContentViewDelegate>)delegate;
- (void)showContent;
- (void)stop;
- (AdPieAdWebView *)getContentsView;

@end

@protocol AdPieAdContentViewDelegate <NSObject>

@optional
- (void)adContentViewDidLoad:(AdPieAdContentView *)adContentView;
- (void)adContentView:(AdPieAdContentView *)adContentView didFailToLoadAdWithError:(NSError *)error;
- (void)adContentViewDidClick:(AdPieAdContentView *)adContentView;
@end

NS_ASSUME_NONNULL_END



