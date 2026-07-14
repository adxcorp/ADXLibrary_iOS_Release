//
//  AdPieAdContentView.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "AdPieAdContentView.h"
#import <ADXLibrary/ADXAdError.h>
#import <ADXLibrary/ADXAdLogEvent.h>
#import <ADXLibrary/ADXHTTPNetworkSession.h>
#import <ADXLibrary/UIColor+ADXHexString.h>

typedef NS_ENUM(NSInteger, AdPieWebViewAdType) {
    AdPieWebViewTypeBanner = 0,
    AdPieWebViewTypeInterstitial
};

@interface AdPieAdContentView () <AdPieAdWebViewDelegate>

@property (strong) AdPieAdData *adData;
@property (strong) NSArray * impressionUrls;
@property (strong) AdPieAdWebView *webView;
@property (assign) AdPieWebViewAdType adType;

@end

@implementation AdPieAdContentView

#pragma mark - View Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [self resizeWebView];
}

- (void)dealloc {
    ADXDebugLog(@"dealloc");
    
    if (self.webView) {
        [self.webView stopLoading];
        self.webView = nil;
    }
    self.delegate = nil;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    
    // 화면에 UIView (WebView)가 보이지 않음
    if(self.window == nil) { return; }
    // 임프레션 URL 없음
    if([self.impressionUrls count] == 0) { return; }
    ADXDebugLog(@"trackImpressionURLs: %@", self.impressionUrls);
    // 임프레션 발생
    for (NSString *string in self.impressionUrls) {
        [ADXHTTPNetworkSession GETStartTaskWithRequestURLString:string];
    }
    // 초기화: didMoveToWindow 메소드가 여러번 호출 될 수 있기 때문에 초기화하여 임프레션을 중복으로 발생하지 않도록)
    self.impressionUrls = [NSArray array];
}

#pragma mark - Public methods

- (AdPieAdWebView *)getContentsView {
    return [self webView];
}

- (void)setBannerAdData:(AdPieAdData *)adData delegate:(id<AdPieAdContentViewDelegate>)delegate {
    self.adType = AdPieWebViewTypeBanner;
    self.adData = adData;
    self.delegate = delegate;
    
    [self setup];
    [self resizeWebView];
}

- (void)setInterstitialAdData:(AdPieAdData *)adData delegate:(id<AdPieAdContentViewDelegate>)delegate {
    self.adType = AdPieWebViewTypeInterstitial;
    self.adData = adData;
    self.delegate = delegate;
    
    [self setup];
    [self resizeWebView];
}

- (void)showContent {
    ADXDebugLog(@"showContent");
    
    if (!self.webView) {
        ADXDebugLogError(@"WebView is nil");
        
        if ([self.delegate respondsToSelector:@selector(adContentView:didFailToLoadAdWithError:)]) {
            [self.delegate adContentView:self didFailToLoadAdWithError:[NSError errorWithCode:ADXAdErrorContentLoad]];
        }
        return;
    }
    
    if (!self.adData) {
        ADXDebugLogError(@"AdData is nil");
        
        if ([self.delegate respondsToSelector:@selector(adContentView:didFailToLoadAdWithError:)]) {
            [self.delegate adContentView:self didFailToLoadAdWithError:[NSError errorWithCode:ADXAdErrorContentLoad]];
        }
    }
    
    self.backgroundColor = [UIColor colorWithHexString:self.adData.bgColor];
    
    NSTimeInterval timeInterval = 0;
    if (self.adType == AdPieWebViewTypeBanner) {
        timeInterval = 2.0f;
        
    } else if (self.adType == AdPieWebViewTypeInterstitial) {
        timeInterval = 0.0f;
    }
    
    [self.webView loadHTMLString:self.adData timeoutInterval:timeInterval];
}

- (void)stop {
    ADXDebugLog(@"stop");
    
    if (self.webView) {
        [self.webView stopLoading];
    }
}


#pragma mark - Private methods

- (void)setup {
    if (self.webView != nil) {
        self.webView.delegate = nil;
        [self.webView removeFromSuperview];
        self.webView = nil;
    }
    
    NSArray * trackImpressionURL = self.adData.trackImpressionURLs;
    self.impressionUrls = @[];
    if([trackImpressionURL count]) {
        self.impressionUrls = [NSArray arrayWithArray:trackImpressionURL];
    }
    
    self.webView = [[AdPieAdWebView alloc] initWithFrame:self.bounds];
    self.webView.delegate = self;
    [self addSubview:self.webView];
}

- (void)resizeWebView {
    if (!self.webView) {
        return;
    }
    
    CGSize webViewSize = CGSizeZero;
    
    if (self.adType == AdPieWebViewTypeBanner) {
        webViewSize = CGSizeMake(320, 50);
        
    } else if (self.adType == AdPieWebViewTypeInterstitial) {
        webViewSize = CGSizeMake(320, 480);
    }
    
    if (self.adData && self.adData.width && self.adData.height) {
        webViewSize = CGSizeMake(self.adData.width, self.adData.height);
    }
    
    CGFloat originX = (self.bounds.size.width - webViewSize.width) / 2;
    CGFloat originY = (self.bounds.size.height - webViewSize.height) / 2;
    
    [self.webView setFrame:CGRectMake(originX, originY, webViewSize.width, webViewSize.height)];
}


#pragma mark - ADXAdWebViewDelegate

- (void)webViewDidLoad:(AdPieAdWebView *)webView {
    ADXDebugLog(@"webViewDidLoad");
    
    if ([self.delegate respondsToSelector:@selector(adContentViewDidLoad:)]) {
        [self.delegate adContentViewDidLoad:self];
    }
}

- (void)webView:(AdPieAdWebView *)webView didFailToLoadAdWithError:(NSError *)error {
    ADXDebugLogError(@"webView:DidFailToLoadAdWithError");
    
    if ([self.delegate respondsToSelector:@selector(adContentView:didFailToLoadAdWithError:)]) {
        [self.delegate adContentView:self didFailToLoadAdWithError:error];
    }
}

- (void)webView:(AdPieAdWebView *)webView didClickWithURL:(NSURL *)url {
    ADXDebugLog(@"webView:DidClickWithURL");
    if ([self.delegate respondsToSelector:@selector(adContentViewDidClick:)]) {
        [self.delegate adContentViewDidClick:self];
    }
}

@end
