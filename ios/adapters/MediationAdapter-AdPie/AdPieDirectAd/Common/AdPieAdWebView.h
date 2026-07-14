//
//  AdPieAdWebView.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "AdPieAdData.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AdPieAdWebViewDelegate;

@interface AdPieAdWebView : UIView

@property (weak, nullable) id<AdPieAdWebViewDelegate> delegate;

- (void)loadHTMLString:(AdPieAdData *)adData timeoutInterval:(NSTimeInterval)timeoutInterval;

- (void)reload;
- (void)stopLoading;
- (void)monitoring:(int)act;
- (CGFloat)getScaleValue:(WKWebView *)webView;

@end

@protocol AdPieAdWebViewDelegate <NSObject>

- (void)webViewDidLoad:(AdPieAdWebView *)webView;
- (void)webView:(AdPieAdWebView *)webView didFailToLoadAdWithError:(NSError *)error;
- (void)webView:(AdPieAdWebView *)webView didClickWithURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
