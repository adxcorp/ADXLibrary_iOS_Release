//
//  AdPieInterstitialAdViewController.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "AdPieInterstitialAdViewController.h"
#import <ADXLibrary/ADXImageConstants.h>
#import <ADXLibrary/ADXAdError.h>
#import <ADXLibrary/ADXAdLogEvent.h>
#import <ADXLibrary/ADXConfiguration.h>
#import <ADXLibrary/ADXHTTPNetworkSession.h>
#import "AdPieAdContentView.h"
#import "AdPieAdData.h"
#import "ADXProgressView.h"


static NSString * const kADXInterstitialTimerNotification = @"ADXInterstitialTimerNotification";

@interface AdPieInterstitialAdViewController () <AdPieAdContentViewDelegate>

@property (strong) UIButton *closeButton;
@property (strong) AdPieAdData *adData;
@property (strong) AdPieAdContentView *adContentView;
@property (strong) ADXProgressView *progressView;
@property (strong) NSTimer * eventTimer;
@property (strong) NSTimer * stopTimer;
@property (strong) NSDate * startTime;
@property BOOL hasAppeared;
@property BOOL hasClicked;

@end

@implementation AdPieInterstitialAdViewController

- (void)dealloc {
    ADXDebugLog(@"dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.adContentView.delegate = nil;
    self.adContentView = nil;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    ADXDebugLog(@"viewDidLoad");
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    ADXDebugLog(@"viewWillDisappear");
    if (self.adContentView) {
        [self.adContentView stop];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ADXDebugLog(@"viewWillAppear");
    [self.adContentView showContent];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    ADXDebugLog(@"viewDidAppear");
    if(self.hasAppeared) { return; }
    self.hasAppeared = YES;
    ADXDebugLog(@"closeButtonDelay: %d", self.adData.closeButtonDelay);
    NSTimeInterval skipOffsetSec = self.adData.closeButtonDelay;
    if (skipOffsetSec < 3) {
        [self showCloseButtonAfterSpecifiedTime:skipOffsetSec];
    } else {
        [self setupProgressTimerEvent:skipOffsetSec];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.adContentView) {
        self.adContentView.frame = self.view.bounds;
    }
}

- (void)showCloseButtonAfterSpecifiedTime:(NSTimeInterval)timeInSeconds {
    /// 3초 미만: 지정된 시간 이후 닫기 버튼 노출
    __weak typeof(self) weakSelf = self;
    NSTimeInterval delayTime = timeInSeconds < 1 ? 0 : timeInSeconds;
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC));
    dispatch_after(delay, dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        if(strongSelf == nil) { return; }
        strongSelf.closeButton.hidden = NO;
    });
}

- (void)setupProgressTimerEvent:(NSTimeInterval)timeInSeconds {
    self.progressView.hidden = NO;
    [self startListeningForDuration:timeInSeconds];
}

#pragma mark - Orientation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIInterfaceOrientationMask mask = [ADXConfiguration plistSupportedOrientations];
    switch(self.adData.orientation)
    {
        case AdPieAdOrientationPortrait:
            if(mask & UIInterfaceOrientationMaskPortrait && mask & UIInterfaceOrientationMaskPortraitUpsideDown)
                return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
            else if(mask & UIInterfaceOrientationMaskPortraitUpsideDown)
                return UIInterfaceOrientationMaskPortraitUpsideDown;
            return UIInterfaceOrientationMaskPortrait;
        case AdPieAdOrientationLandscape:
            if(mask & UIInterfaceOrientationMaskLandscapeLeft && mask & UIInterfaceOrientationMaskLandscapeRight){
                return UIInterfaceOrientationMaskLandscape;
            }else if(mask & UIInterfaceOrientationMaskLandscapeLeft){
                return UIInterfaceOrientationMaskLandscapeLeft;
            }else if(mask & UIInterfaceOrientationMaskLandscapeRight){
                return UIInterfaceOrientationMaskLandscapeRight;
            }
        default:
            return UIInterfaceOrientationMaskAll;
    }
}

#pragma mark - Public methods

- (void)loadAdWithData:(AdPieAdData *)adData {
    ADXDebugLog(@"loadAdWithData");
    
    if (adData == nil) {
        if ([self.delegate respondsToSelector:@selector(interstitialAdDidFailToLoadWithError:)]) {
            [self.delegate interstitialAdDidFailToLoadWithError:[NSError errorWithCode:ADXAdErrorServerData]];
        }
        return;
    }
    
    self.adData = adData;
    [self setup];
    
    if ([self.delegate respondsToSelector:@selector(interstitialAdDidLoad)]) {
        [self.delegate interstitialAdDidLoad];
    }
}


#pragma mark - Private methods

- (void)setup {
    ADXDebugLog(@"setup");
    self.view.backgroundColor = [UIColor clearColor];
    [self contentViewSetup];
    [self setupCloseButton];
    [self setupProgressView];
}

- (void)contentViewSetup {
    self.adContentView = [[AdPieAdContentView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_adContentView];
    _adContentView.translatesAutoresizingMaskIntoConstraints = NO;
    UILayoutGuide * guide = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [_adContentView.topAnchor constraintEqualToAnchor:guide.topAnchor constant:0],
        [_adContentView.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor constant:0],
        [_adContentView.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor constant:0],
        [_adContentView.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor constant:0]
    ]];
    [self.adContentView setInterstitialAdData:self.adData delegate:self];
}

- (void)setupCloseButton {
    self.closeButton = [UIButton new];
    UIImage * closeImage = ADXDecodedBase64ToEncodedString(ADXCircleCloseIconEncodedImage);
    [self.closeButton setImage:closeImage forState:UIControlStateNormal];
    
    [self.closeButton addTarget:self
                         action:@selector(closeAd)
               forControlEvents:UIControlEventTouchUpInside];
    
    self.closeButton.clipsToBounds = YES;
    self.closeButton.hidden = YES;
    
    /// AutoLayout (웹뷰의 우측 상단)
    AdPieAdWebView * webView = (AdPieAdWebView *)[_adContentView getContentsView];
    [webView addSubview:self.closeButton];
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    /// WebView의 기본 사이즈 (320 x 480) 에서 확대 될 크기를 고려하여 topAnchor, trailingAnchor 설정
    CGFloat scale = [webView getScaleValue:(WKWebView *)webView];
    CGFloat xPosition = (webView.frame.size.width - webView.frame.size.width * scale) / 2;
    CGFloat yPosition = (webView.frame.size.height - webView.frame.size.height * scale) /2;
    [NSLayoutConstraint activateConstraints:@[
        [self.closeButton.topAnchor constraintEqualToAnchor:webView.topAnchor constant:yPosition],
        [self.closeButton.trailingAnchor constraintEqualToAnchor:webView.trailingAnchor constant:-xPosition],
        [self.closeButton.widthAnchor constraintEqualToConstant:28],
        [self.closeButton.heightAnchor constraintEqualToConstant:28]
    ]];
}

- (void)closeAd {
    ADXDebugLog(@"closeAd");
    
    // 매체에 종료 예정 알림
    if ([self.delegate respondsToSelector:@selector(interstitialAdWillDismissScreen)]) {
        [self.delegate interstitialAdWillDismissScreen];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        // 매체에 종료 완료 알림
        if ([weakSelf.delegate respondsToSelector:@selector(interstitialAdDidDismissScreen)]) {
            [weakSelf.delegate interstitialAdDidDismissScreen];
        }
    }];
}

- (void)setupProgressView {
    self.progressView = [ADXProgressView new];
    self.progressView.borderWidth = 1.0;
    self.progressView.lineWidth = 5.0;
    self.progressView.tintColor = [UIColor colorWithRed:68.0/255.0 green:200.0/255.0 blue:229.0/255.0 alpha:255.0/255.0];
    self.progressView.fillOnTouch = NO;
    
    UILabel * centerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 32.0, 32.0)];
    centerLabel.font = [UIFont systemFontOfSize:10];
    centerLabel.textAlignment = NSTextAlignmentCenter;
    centerLabel.textColor = [UIColor whiteColor];
    centerLabel.backgroundColor = [UIColor clearColor];
    self.progressView.centralView = centerLabel;
    
    self.progressView.hidden = YES;

    /// AutoLayout (화면의 우측 상단)
    [self.view addSubview:self.progressView];
    self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.progressView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:15],
        [self.progressView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-15],
        [self.progressView.widthAnchor constraintEqualToConstant:32],
        [self.progressView.heightAnchor constraintEqualToConstant:32]
    ]];
}


#pragma mark - ADXAdContentViewDelegate

- (void)adContentViewDidLoad:(AdPieAdContentView *)adContentView {
    ADXDebugLog(@"adContentViewDidLoad");
    
    if ([self.delegate respondsToSelector:@selector(interstitialAdDidLoad)]) {
        [self.delegate interstitialAdDidLoad];
    }
}

- (void)adContentView:(AdPieAdContentView *)adContentView didFailToLoadAdWithError:(NSError *)error {
    ADXDebugLog(@"adContentViewDidFailToLoadAdWithError");
    
    if ([self.delegate respondsToSelector:@selector(interstitialAdDidFailToLoadWithError:)]) {
        [self.delegate interstitialAdDidFailToLoadWithError:error];
    }
}

- (void)adContentViewDidClick:(AdPieAdContentView *)adContentView {
    ADXDebugLog(@"adContentViewDidClick");
    if ([self.delegate respondsToSelector:@selector(interstitialAdDidClick)]) {
        [self.delegate interstitialAdDidClick];
    }
    
    if(self.hasClicked == NO) {
        self.hasClicked = YES;
        ADXDebugLog(@"trackClickURLs: %@", self.adData.trackClickURLs);
        if([self.adData.trackClickURLs count] <= 0 ) { return; }
        for (NSString *string in self.adData.trackClickURLs) {
            [ADXHTTPNetworkSession GETStartTaskWithRequestURLString:string];
        }
    }
}

#pragma mark Timer Events
- (void)startListeningForDuration:(NSTimeInterval)duration {
    
    // 현재 시간을 시작 시간으로 설정
    self.startTime = [NSDate date];
    
    // 이벤트 수신 등록
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleEvent:)
                                                 name:kADXInterstitialTimerNotification
                                               object:nil];

    // (1/60) 초 간격으로 이벤트 발생
    [self startGeneratingEvents];
    
    // 지정된 시간 후 리스너 제거
    __weak typeof(self) weakSelf = self;
    self.stopTimer = [NSTimer scheduledTimerWithTimeInterval:duration
                                                     repeats:NO
                                                       block:^(NSTimer * _Nonnull timer) {
        [weakSelf stopListening];
    }];
}

- (void)startGeneratingEvents {
    __weak typeof(self) weakSelf = self;
    self.eventTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0/60.0)
                                                      repeats:YES
                                                        block:^(NSTimer * _Nonnull timer) {
        [weakSelf postEvent];
    }];
}

- (void)postEvent {
    [[NSNotificationCenter defaultCenter] postNotificationName:kADXInterstitialTimerNotification object:nil];
}

- (void)stopListening {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kADXInterstitialTimerNotification object:nil];
    [self.eventTimer invalidate];
    self.eventTimer = nil;
    [self.stopTimer invalidate];
    self.stopTimer = nil;
    self.progressView.hidden = YES;
    self.closeButton.hidden = NO;
}

- (void)handleEvent:(NSNotification *)notification {
    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:self.startTime];
    [self.progressView setProgress:(elapsedTime / self.adData.closeButtonDelay)];
    UILabel * timeLabel = (UILabel *)self.progressView.centralView;
    [timeLabel setText:[NSString stringWithFormat:@"%d", (int)ceil(self.adData.closeButtonDelay-elapsedTime)]];
}

@end
