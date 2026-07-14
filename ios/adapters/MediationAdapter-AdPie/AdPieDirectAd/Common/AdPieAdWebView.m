//
//  AdPieAdWebView.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "AdPieAdWebView.h"
#import <ADXLibrary/ADXConfiguration.h>
#import <ADXLibrary/ADXAdError.h>
#import <ADXLibrary/ADXAdLogEvent.h>

@interface AdPieAdWebView () <WKNavigationDelegate, WKUIDelegate, UIGestureRecognizerDelegate>

@property (strong) WKWebView *webView;
@property (strong) NSTimer *timer;
@property (assign) NSTimeInterval timeoutInterval;
@property (assign, getter=isFinished) BOOL finished;
@property (assign, getter=isPressed) BOOL pressed;
@property (assign) int act;
@property (strong) AdPieAdData *adData;


@end

@implementation AdPieAdWebView


#pragma mark - View Lifecycle

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setup];
    }
    
    return self;
}

- (void)awakeFromNib {
    [self setup];
    [super awakeFromNib];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (self.webView) {
        [self.webView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.delegate = nil;
}

#pragma mark - Public methods

- (void)loadHTMLString:(AdPieAdData *)adData timeoutInterval:(NSTimeInterval)timeoutInterval {
    self.finished = NO;
    self.adData = adData;
    
    self.timeoutInterval = timeoutInterval;
    
    if (self.webView) {
        if ([adData.adm length]) {
            [self.webView loadHTMLString:adData.adm baseURL:nil];
            
            if (self.timeoutInterval > 0) {
                ADXDebugLog(@"Webview timeoutInterval - %g", timeoutInterval);
                
                // Timer 시작
                __weak typeof(self) weakSelf = self;
                self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeoutInterval repeats:NO block:^(NSTimer * _Nonnull timer) {
                    [weakSelf timeoutWebView];
                }];
            }
        } else {
            ADXDebugLogError(@"Adm cannot be nil");
            
            if ([self.delegate respondsToSelector:@selector(webView:didFailToLoadAdWithError:)]) {
                [self.delegate webView:self didFailToLoadAdWithError:[NSError errorWithCode:ADXAdErrorContentLoad]];
            }
        }
    } else {
        ADXDebugLogError(@"WebView cannot be nil");
        
        if ([self.delegate respondsToSelector:@selector(webView:didFailToLoadAdWithError:)]) {
            [self.delegate webView:self didFailToLoadAdWithError:[NSError errorWithCode:ADXAdErrorContentLoad]];
        }
    }
}

- (void)reload {
    if (self.webView) {
        [self.webView reload];
    }
}

- (void)stopLoading {
    if (self.webView) {
        [self.webView stopLoading];
    }
}

- (void)monitoring:(int)act {
    self.act = act;
}


#pragma mark - Private methods

- (void)setup {
    self.finished = NO;
    
    self.backgroundColor = [UIColor clearColor];
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.bounds];
    webView.backgroundColor = [UIColor clearColor];
    webView.navigationDelegate = self;
    webView.UIDelegate = self;
    webView.scrollView.scrollEnabled = NO;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTapGesture:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.delegate = self;
    [webView addGestureRecognizer:tapRecognizer];
    
    self.webView = webView;
    
    [self addSubview:webView];
    
    /// 백그라운드-포어그라운드 전환 간, 확대한 WebView 크기의 초기화 문제로 인하여, transform 값을 초기화 및 복구하기 위해서 옵저버 추가.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scaleUpTransform)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(restoreTransform)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // 확대된 크기에 맞게 터치 감지 영역 계산
    CGAffineTransform transform = self.webView.transform;
    CGFloat scaleX = sqrt(transform.a * transform.a + transform.c * transform.c); // X 스케일
    CGFloat scaleY = sqrt(transform.b * transform.b + transform.d * transform.d); // Y 스케일
    
    CGRect expandedBounds = self.bounds;
    expandedBounds.size.width *= scaleX;
    expandedBounds.size.height *= scaleY;
    
    // 중심을 기준으로 좌표 보정
    expandedBounds.origin.x = self.bounds.origin.x - (expandedBounds.size.width - self.bounds.size.width) / 2;
    expandedBounds.origin.y = self.bounds.origin.y - (expandedBounds.size.height - self.bounds.size.height) / 2;
    
    return CGRectContainsPoint(expandedBounds, point);
}

- (void)timeoutWebView {
    ADXDebugLog(@"timeoutWebView");
    
    if (!self.isFinished) {
        self.finished = YES;
        
        ADXDebugLogError(@"WebView loading time is delayed.");
        
        // 딜레이로 인해 타임아웃 뜬 것일 뿐 데이터는 로딩됐을 수 있으므로 load 처리
        if ([self.delegate respondsToSelector:@selector(webViewDidLoad:)]) {
            [self.delegate webViewDidLoad:self];
        }
    }
}

- (void)respondToTapGesture:(UITapGestureRecognizer *)recognizer {
    ADXDebugLog(@"Tap");
    
    self.pressed = YES;
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.pressed = NO;
    });
}

- (CGFloat)getScaleValue:(WKWebView *)webView {
    /// Portrait 지원하는지 확인
    UIInterfaceOrientationMask mask = [ADXConfiguration plistSupportedOrientations];
    BOOL supportsPortrait = NO;
    if(mask & UIInterfaceOrientationMaskPortrait){
        supportsPortrait = YES;
    } else {
        ADXDebugLog(@"No Support Portrait");
        return 1.0;
    }
    /// iPad 경우,   "Requires full screen' 옵션 설정이 안되어 있는 경우, 확대하지 않음.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        /// If 'Requires full screen' setting from 'General' is enable, will allow the orientation delegate methods shouldAutorotate, preferredInterfaceOrientation, and supportedInterfaceOrientations to fire.
        BOOL requiresFullScreen = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIRequiresFullScreen"] boolValue];
        if (requiresFullScreen == NO) {
            ADXDebugLog(@"No Support 'requiresFullScreen'");
            return 1.0;
        }
    }
    
    /// 웹뷰 크기
    CGFloat contentWidth = webView.frame.size.width;
    CGFloat contentHeight = webView.frame.size.height;
    ADXDebugLog(@"contentWidth: %f, contentHeight: %f", contentWidth, contentHeight);
    
    /// SuperView 프레임 크기
    CGFloat frameWidth = self.superview.frame.size.width;
    CGFloat frameHeight = self.superview.frame.size.height;
    if(frameWidth > frameHeight) {
        frameWidth = self.superview.frame.size.height;
        frameHeight = self.superview.frame.size.width;
    }
    ADXDebugLog(@"frameWidth: %f, frameHeight: %f", frameWidth, frameHeight);
    
    /// 확대 비율 계산 (너비와 높이 중, 작은 값으로 사용)
    CGFloat scaleX = frameWidth / contentWidth;
    CGFloat scaleY = frameHeight / contentHeight;
    CGFloat scale = MIN(scaleX, scaleY);
    ADXDebugLog(@"scale: %f", scale);
    return scale;
}

- (void)scaleUpTransform {
    WKWebView * webView = self.webView;
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    __weak typeof(self) weakSelf = self;
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        __typeof__(self) strongSelf = weakSelf;
        if(!strongSelf) { return; }
        [strongSelf scaleUpWebViewContents:webView];
    });
}

- (void)restoreTransform {
    WKWebView * webView = self.webView;
    if(webView) {
        webView.transform = CGAffineTransformIdentity;
    }
}

- (void)scaleUpWebViewContents:(WKWebView *)webView {
    
    if(webView == nil) { return; }
    
    if(self.adData.icType != AdPieAdContentTypeInterstitalImage) {
        ADXDebugLog(@"not AdPieAdContentTypeInterstitalImage (type: %d)", self.adData.icType);
        return;
    }
    /// 확대 비율 값 가져오기.
    CGFloat scale = [self getScaleValue:webView];
    
    /// 확대 시, 애니메이션 적용.
    [UIView animateWithDuration:0.3 animations:^{
        webView.transform = CGAffineTransformMakeScale(scale, scale);
    }];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    ADXDebugLog(@"didStartProvisionalNavigation");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    ADXDebugLog(@"didFinishNavigation");
    
    if (!self.isFinished) {
        if (webView) {
            if (webView.isLoading) {
                ADXDebugLog(@"WebView is loading.");
                
            } else {
                // 웹뷰가 컨텐츠를 모두 읽은 후에 실행
                self.finished = YES;
                
                [self scaleUpWebViewContents:webView];
                
                if (self.timer) {
                    [self.timer invalidate];
                    self.timer = nil;
                }
                
                if ([self.delegate respondsToSelector:@selector(webViewDidLoad:)]) {
                    [self.delegate webViewDidLoad:self];
                }
            }
        } else {
            ADXDebugLogError(@"WebView is nil");
        }
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    // 컨텐츠를 읽는 도중 오류가 발생할 경우 실행
    ADXDebugLog(@"didFailNavigation");
    
    if ([self.delegate respondsToSelector:@selector(webView:didFailToLoadAdWithError:)]) {
        [self.delegate webView:self didFailToLoadAdWithError:error];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *urlString = navigationAction.request.URL.absoluteString;
    
    ADXDebugLog(@"decidePolicyForNavigationAction - Request URL: %@", urlString);
    ADXDebugLog(@"isPressed: %d, act: %d", self.isPressed, self.act);
    
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        ADXDebugLog(@"decidePolicyForNavigationAction - WKNavigationTypeLinkActivated");

        NSURL *url = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        
        if ([self.delegate respondsToSelector:@selector(webView:didClickWithURL:)]) {
            [self.delegate webView:self didClickWithURL:url];
        }
        
        decisionHandler(WKNavigationActionPolicyCancel); // Cancel the navigation
        return;
        
    } else if (self.isPressed && navigationAction.navigationType == WKNavigationTypeOther) {
        ADXDebugLog(@"decidePolicyForNavigationAction - WKNavigationTypeOther");
        
        NSURL *url = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        
        if ([self.delegate respondsToSelector:@selector(webView:didClickWithURL:)]) {
            [self.delegate webView:self didClickWithURL:url];
        }
        
        decisionHandler(WKNavigationActionPolicyCancel); // Cancel the navigation
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow); // Allow the navigation
}


#pragma mark - WKUIDelegate

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    NSString *urlString = navigationAction.request.URL.absoluteString;
    ADXDebugLog(@"createWebViewWithConfiguration - Request URL: %@", urlString);
    
    if (!navigationAction.targetFrame.isMainFrame) {
        if ([[UIApplication sharedApplication] canOpenURL:navigationAction.request.URL]) {
            // 팝업(새 창) 뜨는 경우 호출됨 (window.open 또는 target="_blank")
            NSURL *url = navigationAction.request.URL;
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            
            if ([self.delegate respondsToSelector:@selector(webView:didClickWithURL:)]) {
                [self.delegate webView:self didClickWithURL:url];
            }
        }
    }
    
    return nil;
}

@end
