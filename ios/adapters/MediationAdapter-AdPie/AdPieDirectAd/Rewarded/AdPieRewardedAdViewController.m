//
//  AdPieRewardedAdViewController.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "AdPieRewardedAdViewController.h"

#import <ADXLibrary/ADXImageConstants.h>
#import <ADXLibrary/ADXHTTPNetworkSession.h>
#import "ADXProgressView.h"
#import <ADXLibrary/ADXAdError.h>
#import <ADXLibrary/ADXAdLogEvent.h>
#import <ADXLibrary/ADXConfiguration.h>

#define btnWidth 32.0f
#define btnHeight 32.0f
#define marginWidth 10.0f
#define marginHeight 10.0f

@interface AdPieRewardedAdViewController ()

@property (strong) UIButton *closeButton;
@property (strong) UIButton *skipButton;
@property (strong) AdPieVideoAdData *adData;
@property (assign, getter=isClicked) BOOL clicked;
@property (assign) BOOL isClickedForEndCard;
@property (strong) AVPlayer *player;
@property (strong) AVPlayerLayer *playerLayer;
@property UIButton *optoutButton;
@property (assign, getter=isSentStart) BOOL sentStart;
@property (assign, getter=isSentComplete) BOOL sentComplete;
@property (strong) UIButton *volumeButton;
@property (assign, getter=isMuted) BOOL muted;
@property (assign) BOOL hasAppeared;
@property (strong) ADXProgressView *progressView;
@property (assign) int skipOffsetSec;
@property UIView *backgroundView;
@property UIImageView *thumnailImageView;
@property UIImageView *endCardImageView;
@property id timeObserver;
@end

typedef NS_ENUM(NSInteger, ADXPlaybackBoundary) {
    ADXPlaybackBoundary25 = 0,
    ADXPlaybackBoundary50,
    ADXPlaybackBoundary75,
    ADXPlaybackBoundary100,
    ADXPlaybackBoundaryCount
};

@implementation AdPieRewardedAdViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    ADXDebugLog(@"viewDidLoad");
    [self setup];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(self.hasAppeared) { return; }
    ADXDebugLog(@"viewDidAppear");
    self.hasAppeared = YES;
    // Impression Tracking
    if (self.adData.trackImpressionURLs && self.adData.trackImpressionURLs.count > 0) {
        for (NSString *string in self.adData.trackImpressionURLs) {
            [ADXHTTPNetworkSession GETStartTaskWithRequestURLString:string];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    ADXDebugLog(@"viewWillAppear");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    ADXDebugLog(@"viewWillDisappear");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //[self.player seekToTime:kCMTimeZero];
    [self.player pause];
    self.player = nil;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIInterfaceOrientationMask mask = [ADXConfiguration plistSupportedOrientations];
    ADXLogInfo(@"orientation : %d, mask : %d", self.adData.orientation, mask);
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

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //ADXDebugLog(@"viewDidLayoutSubviews");
    self.playerLayer.frame = self.view.bounds;
    self.backgroundView.frame = self.view.bounds;
    self.thumnailImageView.frame = self.playerLayer.videoRect;
}

#pragma mark Notifications

- (void)appDidBecomeActive:(NSNotification *)notification {
    ADXDebugLog(@"appDidBecomeActive");
    if (self.player.timeControlStatus != AVPlayerTimeControlStatusPlaying) {
        [self.player play];
    }
}

- (void)appWillResignActive:(NSNotification *)notification {
    ADXDebugLog(@"appWillResignActive");
    [self.player pause];
}

#pragma mark - Private methods

- (void)isVideoPlayableWithURL:(NSURL *)url completion:(void (^)(BOOL playable, AVPlayer * player))completion {
    // 재생 가능한 컨텐츠 여부 확인
    AVAsset * videoAsset = [AVAsset assetWithURL:url];
    AVPlayerItem * playerItem = [AVPlayerItem playerItemWithAsset:videoAsset];
    // 참조:
    // https://developer.apple.com/documentation/avfoundation/avasynchronouskeyvalueloading/1387321-loadvaluesasynchronouslyforkeys
    // https://developer.apple.com/documentation/avfoundation/avasset/1385974-playable
    // playable: A Boolean value that indicates whether the asset has playable content.
    [videoAsset loadValuesAsynchronouslyForKeys:@[@"playable"] completionHandler:^{
        NSError *error = nil;
        AVKeyValueStatus status = [videoAsset statusOfValueForKey:@"playable" error:&error];
        switch (status) {
            case AVKeyValueStatusLoaded:
            {
                ADXLogInfo(@"AVKeyValueStatusLoaded");
                AVPlayer * player = [AVPlayer playerWithPlayerItem:playerItem];
                dispatch_async(dispatch_get_main_queue(), ^{ completion(videoAsset.isPlayable, player); });
                break;
            }
            default:
                ADXLogInfo(@"AVKeyValueStatus: %d", status);
                if(error) { ADXLogInfo(@"error: %@",error); }
                dispatch_async(dispatch_get_main_queue(), ^{ completion(NO, nil); });
                break;
        }
    }];
    
}

- (void)setup {
    if (!self.adData.content) {
        ADXLogInfo(@"setup failed, self.adData.content is nil");
        return;
    }
    /// Skip Offset Time
    [self setupSkipOffsetTimeInSeconds:self.adData.skipOffset];
    
    /// BackgroundView
    [self setupBackgroundView];
    
    __weak typeof(self) weakSelf = self;
    NSURL * url = [NSURL URLWithString:[self.adData content]];
    [self isVideoPlayableWithURL:url completion:^(BOOL playable, AVPlayer * player) {
        __strong typeof(self) strongSelf = weakSelf;
        if(!strongSelf) { return; }
        if(!playable) {
            ADXLogInfo(@"the video contents cannot be loaded.");
            [strongSelf closeAd];
            return;
        }
        /// Setup AVPlayer
        [strongSelf setupAVPlayer:player];
        /// AVPlayerLayer
        [strongSelf setupAVPlayerLayer:strongSelf.player];
        /// Thumnail ImageView
        [strongSelf setupThumnailImageView:strongSelf.playerLayer.videoRect];
        /// End-Card ImageView
        [strongSelf setupEndCardImageView];
        /// Progress View
        [strongSelf setupProgressView];
        /// Close Button
        [strongSelf setupCloseButtonView];
        /// OptOut Button
        [strongSelf setupOptoutButtonView];
        /// Volume Button
        [strongSelf setupVolumeButtonView];
        /// Skip button
        [strongSelf setupSkipButton];
        /// Play Video
        if (strongSelf.player.timeControlStatus != AVPlayerTimeControlStatusPlaying) {
            [strongSelf.player play];
        }
    }];
}

- (BOOL)isLandscape {
    return self.view.bounds.size.width > self.view.bounds.size.height;
}

- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    NSData *data = [[NSData alloc]
                    initWithBase64EncodedString:strEncodeData
                    options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

- (void)imageFromURL:(NSString *)urlString completion:(void (^)(UIImage *image))completion {
    if (![urlString length]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) { completion(nil); }
        });
        return;
    }
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlString]
                                                                 completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        if (error || !data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) { completion(nil); }
            });
            return;
        }

        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) { completion(image); }
        });
    }];
    [dataTask resume];
}

- (void)setupEndCardImageView {
    
    AdPieEndCardData * endCardData = [self.adData endCard];
    
    if(endCardData == nil) { return; }
    NSString * urlString = [endCardData staticResource];
    if(![urlString length]) { return; }
    
    self.endCardImageView = [UIImageView new];
    self.endCardImageView.hidden = YES;
    
    [self.view addSubview:self.endCardImageView];
    self.endCardImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.endCardImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UILayoutGuide *safeAreaGuide = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.endCardImageView.topAnchor constraintEqualToAnchor:safeAreaGuide.topAnchor constant:0],
        [self.endCardImageView.leadingAnchor constraintEqualToAnchor:safeAreaGuide.leadingAnchor constant:0],
        [self.endCardImageView.trailingAnchor constraintEqualToAnchor:safeAreaGuide.trailingAnchor constant:0]
    ]];
    
    NSLayoutYAxisAnchor * bottomAnchor = [self isLandscape] ? self.view.bottomAnchor : safeAreaGuide.bottomAnchor;
    [NSLayoutConstraint activateConstraints:@[
        [self.endCardImageView.bottomAnchor constraintEqualToAnchor:bottomAnchor constant:0]
    ]];
    
    [self.endCardImageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endCardImageViewTapped)];
    [self.endCardImageView addGestureRecognizer:tap];
    
    __weak typeof(self) weakSelf = self;
    [self imageFromURL:urlString completion:^(UIImage *image) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        [strongSelf.endCardImageView setImage:image];
    }];
}

- (void)setupSkipOffsetTimeInSeconds:(int)skipOffset {
    self.skipOffsetSec = skipOffset;
    if (self.adData.icType == AdPieAdContentTypeRewardedVideo){
        if (self.skipOffsetSec > 0 && self.skipOffsetSec < 5) {
            self.skipOffsetSec = 5;
        }
    }else{
        if (self.skipOffsetSec > 0 && self.skipOffsetSec < 3) {
            self.skipOffsetSec = 3;
        }
    }
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
    
    if (self.skipOffsetSec > 0) {
        [(UILabel *) self.progressView.centralView setText:[NSString stringWithFormat:@"%d", self.skipOffsetSec]];
    }
    
    self.progressView.hidden = (self.skipOffsetSec == 0);
    
    // 오토레이아웃 (우측 상단)
    [self.view addSubview:self.progressView];
    self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.progressView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:15],
        [self.progressView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-15],
        [self.progressView.widthAnchor constraintEqualToConstant:32],
        [self.progressView.heightAnchor constraintEqualToConstant:32]
    ]];
}

- (void)setupSkipButton {
    self.skipButton = [UIButton new];
    UIImage * closeImage = ADXDecodedBase64ToEncodedString(ADXSkipButtonEncodedImage);
    [self.skipButton setImage:closeImage forState:UIControlStateNormal];
    
    [self.skipButton addTarget:self
                        action:@selector(skipButtonPressed)
              forControlEvents:UIControlEventTouchUpInside];
    
    self.skipButton.clipsToBounds = YES;
    self.skipButton.hidden = YES;
    
    // AutoLayout (우측 상단)
    [self.view addSubview:self.skipButton];
    self.skipButton.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.skipButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:15],
        [self.skipButton.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-15],
        [self.skipButton.widthAnchor constraintEqualToConstant:28],
        [self.skipButton.heightAnchor constraintEqualToConstant:28]
    ]];
}

- (void)setupCloseButtonView {
    self.closeButton = [UIButton new];
    UIImage * closeImage = ADXDecodedBase64ToEncodedString(ADXCircleCloseIconEncodedImage);
    [self.closeButton setImage:closeImage forState:UIControlStateNormal];
    
    [self.closeButton addTarget:self
                         action:@selector(closeAd)
               forControlEvents:UIControlEventTouchUpInside];
    
    self.closeButton.clipsToBounds = YES;
    self.closeButton.hidden = YES;
    self.closeButton.hidden = (self.skipOffsetSec != 0);
    
    // AutoLayout (우측 상단)
    [self.view addSubview:self.closeButton];
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.closeButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:15],
        [self.closeButton.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-15],
        [self.closeButton.widthAnchor constraintEqualToConstant:28],
        [self.closeButton.heightAnchor constraintEqualToConstant:28]
    ]];
}

- (void)setupOptoutButtonView {
    self.optoutButton = [UIButton new];
    
    NSString *urlString = [self.adData optoutImageURL];
    if (![urlString length]) { return; }
    
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) { return; }
    
    __weak typeof(self) weakSelf = self;
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url
                                                             completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        if (error || ![data length]) { return; }
        
        UIImage *image = [UIImage imageWithData:data];
        if (!image) { return; }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            if (!strongSelf) { return; }
            
            [strongSelf.optoutButton setImage:image forState:UIControlStateNormal];
            [strongSelf.optoutButton addTarget:strongSelf
                                        action:@selector(optoutButtonPressed)
                              forControlEvents:UIControlEventTouchUpInside];
            strongSelf.optoutButton.clipsToBounds = YES;
            [strongSelf.view addSubview:strongSelf.optoutButton];
            
            // AutoLayout (우측 하단)
            strongSelf.optoutButton.translatesAutoresizingMaskIntoConstraints = NO;
            UILayoutGuide *safeAreaLayoutGuide = strongSelf.view.safeAreaLayoutGuide;
            [NSLayoutConstraint activateConstraints:@[
                [strongSelf.optoutButton.bottomAnchor constraintEqualToAnchor:safeAreaLayoutGuide.bottomAnchor constant:-5],
                [strongSelf.optoutButton.trailingAnchor constraintEqualToAnchor:safeAreaLayoutGuide.trailingAnchor constant:-5],
                [strongSelf.optoutButton.widthAnchor constraintEqualToConstant:20],
                [strongSelf.optoutButton.heightAnchor constraintEqualToConstant:20]
            ]];
        });
    }];
    
    [task resume];
}

- (void)setupVolumeButtonView {
    self.volumeButton = [UIButton new];
    UIImage *volumeOnImage = ADXDecodedBase64ToEncodedString(ADXVolumeOnIconEncodedImage);
    [self.volumeButton setImage:volumeOnImage forState:UIControlStateNormal];
    [self.volumeButton addTarget:self
                          action:@selector(changeVolume)
                forControlEvents:UIControlEventTouchUpInside];
    self.volumeButton.clipsToBounds = YES;
    // AutoLayout (좌측 상단)
    [self.view addSubview:self.volumeButton];
    self.volumeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.volumeButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:15],
        [self.volumeButton.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:15],
        [self.volumeButton.widthAnchor constraintEqualToConstant:32],
        [self.volumeButton.heightAnchor constraintEqualToConstant:32]
    ]];
}

- (void)setupBackgroundView {
    self.view.backgroundColor = [UIColor blackColor];
    self.backgroundView = [[UIView alloc] init];
    self.backgroundView.frame = self.view.bounds;
    [self.view addSubview:self.backgroundView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickLink)];
    [self.backgroundView addGestureRecognizer:tap];
}

- (void)setupThumnailImageView:(CGRect)frame{
    // 썸네일 이미지뷰 생성
    self.thumnailImageView = [[UIImageView alloc] init];
    self.thumnailImageView.frame = frame;
    [self.view addSubview:self.thumnailImageView];
}

- (void)setupAVPlayerLayer:(AVPlayer *)player {
    if(!player) { return; }
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    self.playerLayer.frame = self.view.bounds;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:self.playerLayer];
}

- (void)setupAVPlayer:(AVPlayer *) player{
    self.player = player;
    self.muted = YES;
    [self.player setMuted:self.isMuted];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    
    __weak typeof(self) weakSelf = self;
    /// Requests the periodic invocation of a given block during playback to report changing time.
    CMTime interval = CMTimeMakeWithSeconds(1.0 / 60.0, NSEC_PER_SEC);
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:interval queue:NULL usingBlock:^(CMTime time) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        [strongSelf updateVideoPlayerState];
    }];
    
    /// Register AVPlayerItemFailedToPlayToEndTimeNotification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePlaybackError:)
                                                 name:AVPlayerItemFailedToPlayToEndTimeNotification
                                               object:self.player.currentItem];
    
    /// Register AVPlayerItemDidPlayToEndTimeNotification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerDidFinishPlaying:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.player.currentItem];
    
    /// 25%, 50%, 75%, 100% 구간마다 Tracking Event 및 rewardedAdDidEarnReward 이벤트 발생을 위한 옵저버 등록
    [self addBoundaryTimeObserver];
}

- (void)handlePlaybackError:(NSNotification *)notification {
    NSError *error = notification.userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey];
    ADXDebugLog(@"Error occured while playing video : %@", error.localizedDescription);
    [self closeAd];
}

- (void)playerDidFinishPlaying:(NSNotification *)notification {
    ADXDebugLog(@"Video finished playing or playback has reached the specified time.");
    
    /// 영상 재생 완료 이벤트 제거
    NSNotificationCenter * notiCenter = [NSNotificationCenter defaultCenter];
    [notiCenter removeObserver:self
                          name:AVPlayerItemDidPlayToEndTimeNotification
                        object:self.player.currentItem];
    
    /// ProgressView 감추기
    self.progressView.hidden = YES;
    
    float duration  = CMTimeGetSeconds(self.player.currentItem.duration);
    float playTime  = CMTimeGetSeconds(self.player.currentTime);
    
    /// 광고 재생이 끝까지 완료 된 경우, AVPlayer 제거 및 썸네일 이미지 보이기
    if(duration - playTime <= 0) {
        [self showThumnailImage];
    }
    
    /// End-Card 미사용 또는 End-Card용 이미지 로드가 안된 경우
    if(self.endCardImageView.image == nil) {
        self.closeButton.hidden = NO;
        return;
    }
    
    /// End-Card 사용 및 End-Card용 이미지 로드 된 경우
    self.skipButton.hidden = !(self.closeButton.hidden);
}

- (void)showThumnailImage {
    self.skipOffsetSec = 0;
    self.closeButton.hidden = NO;
    self.progressView.hidden = YES;
    
    __weak typeof(self) weakSelf = self;
    AVPlayerItem * currentItem = self.player.currentItem;
    long lastFrameTime = CMTimeGetSeconds(currentItem.duration);
    [self generateThumbnailFromAsset:[currentItem asset]
                              atTime:CMTimeMakeWithSeconds(lastFrameTime, 60)
                          completion:^(UIImage * thumbnail) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf || thumbnail == nil) { return; }
        if(strongSelf.player != nil) {
            [strongSelf.player pause];
        }
        if([strongSelf.playerLayer superlayer]) {
            [strongSelf.playerLayer removeFromSuperlayer];
        }
        [strongSelf.thumnailImageView setImage:thumbnail];
    }];
}

- (void)generateThumbnailFromAsset:(AVAsset *)asset
                            atTime:(CMTime)time
                        completion:(void (^)(UIImage *thumbnail))completion
{
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    // 요청한 시간 전후 허용 오차 설정
    //imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    //imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    imageGenerator.requestedTimeToleranceBefore = CMTimeMakeWithSeconds(1, 60);
    imageGenerator.requestedTimeToleranceAfter = CMTimeMakeWithSeconds(1, 60);
    // 요청 시간 설정 (NSValue 배열로 전달)
    NSValue *requestedTime = [NSValue valueWithCMTime:time];
    // 비동기적으로 이미지 생성
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime,
                                                       CGImageRef image,
                                                       CMTime actualTime,
                                                       AVAssetImageGeneratorResult result,
                                                       NSError *error)
    {
        if (result != AVAssetImageGeneratorSucceeded) {
            ADXLogInfo(@"couldn't generate thumbnail, error:%@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil);
            });
            return;
        }
        UIImage * thumbnailImage = [UIImage imageWithCGImage:image];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(thumbnailImage);
        });
    };
    
    [imageGenerator generateCGImagesAsynchronouslyForTimes:@[requestedTime]
                                         completionHandler:handler];
}

- (void)updateVideoPlayerState {
    
    float duration  = CMTimeGetSeconds(self.player.currentItem.duration);
    float playTime  = CMTimeGetSeconds(self.player.currentTime);
    
    [self sendStartTrackingUrlEvent:duration];
    
    if (self.skipOffsetSec > 0) {
        /// 지정된 시간 (skipOffsetSec) 만큼 광고를 시청해야 되는 경우
        int diffTime = self.skipOffsetSec - playTime; // (스킵 가능한 시간 - 재생 시간)
        if (diffTime > 0) {
            // 시청해야 될 시간이 남은 경우 (재생 시간 / 광고를 재생해야 될 시간)
            [self.progressView setProgress:(playTime / self.skipOffsetSec)];
            UILabel * timeLabel = (UILabel *)self.progressView.centralView;
            [timeLabel setText:[NSString stringWithFormat:@"%d", diffTime]];
        } else {
            // 지정된 광고 시청 시간이 지난 경우 (100%)
            [self.progressView setProgress:1];
            /// 1초 간격으로 발생하는 영상 재생 이벤트 제거
            [self stopVideoPlayerState];
            /// 스킵 또는 닫기 버튼 노출
            [self playerDidFinishPlaying:nil];
        }
    } else if (self.skipOffsetSec == 0) {
        /// 광고 재생 시간 상관없이, 닫기 버튼 노출
        self.progressView.hidden = YES;
        self.closeButton.hidden = NO;
        /// 1초 간격으로 발생하는 영상 재생 이벤트 제거
        [self stopVideoPlayerState];
        /// 영상 재생 완료 이벤트 제거
        NSNotificationCenter * notiCenter = [NSNotificationCenter defaultCenter];
        [notiCenter removeObserver:self
                              name:AVPlayerItemDidPlayToEndTimeNotification
                            object:self.player.currentItem];
    } else {
        /// 광고 영상을 끝까지 시청해야 하는 경우
        if(isnan(duration)) {
            self.progressView.hidden = YES;
            self.closeButton.hidden = YES;
            return;
        }
        
        [self.progressView setProgress:(playTime / duration)];
        
        int diffTime = duration - playTime;
        UILabel * timeLabel = (UILabel *)self.progressView.centralView;
        if (diffTime > 0) {
            [timeLabel setText:[NSString stringWithFormat:@"%d", diffTime + 1]];
        } else {
            [timeLabel setText:[NSString stringWithFormat:@"%d", 1]];
        }
    }
}

- (void)stopVideoPlayerState {
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
}

- (void)updatePalyerLayout {
    self.playerLayer.frame = self.view.bounds;
    self.backgroundView.frame = self.view.bounds;
    self.thumnailImageView.frame = self.playerLayer.videoRect;
    
    if (self.closeButton) {
        CGFloat btnX = (self.view.bounds.size.width - btnWidth) - marginWidth;
        CGFloat btnY = marginHeight;
        
        if (@available(iOS 11, *)) {
            CGFloat safeAreaWidth = self.view.bounds.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right;
            btnX = safeAreaWidth - btnWidth - marginHeight;
            btnY = self.view.safeAreaInsets.top + marginHeight;
        }
        
        self.closeButton.frame = CGRectMake(btnX, btnY, btnWidth, btnHeight);
        
        if (self.progressView) {
            self.progressView.frame = CGRectMake(btnX, btnY, btnWidth, btnHeight);
        }
    }
    
    if (self.optoutButton) {
        CGFloat optoutBtnWidth = 20.0f;
        CGFloat optoutBtnHeight = 20.0f;
        CGFloat optoutBtnX = optoutBtnWidth;
        CGFloat optoutBtnY = marginHeight;
        if (@available(iOS 11, *)) {
            optoutBtnX = self.view.safeAreaInsets.left + optoutBtnX + 10;
            optoutBtnY = self.view.safeAreaInsets.top + marginHeight;
        }
        self.optoutButton.frame = CGRectMake(optoutBtnX, optoutBtnY, optoutBtnWidth, optoutBtnHeight);
    }
    
    if (self.volumeButton) {
        CGFloat volumeWidth = 30.0f;
        CGFloat volumeHeight = 30.0f;
        CGFloat volumeMaginWidth = 0.0f;
        CGFloat volumeMaginHeight = 20.0f;
        CGFloat volumeX = volumeWidth + volumeMaginWidth;
        CGFloat volumeY = self.view.frame.size.height - volumeHeight - volumeMaginHeight;
        if (@available(iOS 11, *)) {
            volumeX = volumeX + self.view.safeAreaInsets.left;
            volumeY = volumeY - self.view.safeAreaInsets.bottom;
        }
        
        self.volumeButton.frame = CGRectMake(volumeX, volumeY, volumeWidth, volumeHeight);
    }
}

- (void)sendTrackingUrl:(NSArray *)urls {
    for (NSString *string in urls) {
        [ADXHTTPNetworkSession GETStartTaskWithRequestURLString:string];
    }
}

- (void)sendStartTrackingUrlEvent:(float)duration {
    if (self.player.timeControlStatus != AVPlayerTimeControlStatusPlaying) { return; }
    if (self.isSentStart) { return; }
    ADXDebugLog(@"AdPieRewardedAdViewController Start");
    self.sentStart = YES;
    // Sends Tracking Start URL
    if(self.adData.trackingStartUrls){
        [self sendTrackingUrl:self.adData.trackingStartUrls];
    }
    /// SkipOffset must be lower than the duration time in seconds
    if(self.skipOffsetSec != 0 && self.skipOffsetSec > duration) {
        self.skipOffsetSec = (int)duration;
    } else if(duration <= 0) {
        self.skipOffsetSec = 0;
    }
}

- (void)addBoundaryTimeObserver {
    CMTime assetDuration = self.player.currentItem.asset.duration;
    ADXDebugLog(@"Boundary, duration in seconds = %.2f", CMTimeGetSeconds(assetDuration));
    
    NSArray<NSValue *> *boundaryTimes = [self createBoundaryTimesWithDuration:assetDuration];
    __block NSInteger boundaryIndex = 0;
    __weak typeof(self) weakSelf = self;

    [self.player addBoundaryTimeObserverForTimes:boundaryTimes
                                           queue:dispatch_get_main_queue()
                                      usingBlock:^{
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf || boundaryIndex >= boundaryTimes.count) {
            return;
        }

        CMTime boundaryTime = [boundaryTimes[boundaryIndex] CMTimeValue];
        NSInteger percentage = (boundaryIndex + 1) * 25;
        ADXDebugLog(@"Reached Boundary %ld%% (%.2f seconds)", (long)percentage, CMTimeGetSeconds(boundaryTime));
        
        NSArray *trackingURLs = [strongSelf trackingURLsForBoundaryIndex:boundaryIndex];
        [strongSelf sendTrackingUrl:trackingURLs];

        if (boundaryIndex == ADXPlaybackBoundary100){
            ADXDebugLog(@"ADXPlaybackBoundary100");
            strongSelf.sentComplete = YES;
        }

        boundaryIndex += 1;
    }];
}

- (NSArray<NSValue *> *)createBoundaryTimesWithDuration:(CMTime)duration {
    NSMutableArray<NSValue *> *times = [NSMutableArray array];
    CMTime interval = CMTimeMultiplyByFloat64(duration, 0.25);
    CMTime currentTime = interval;
    for (NSInteger i = 1; i <= ADXPlaybackBoundaryCount; i++) {
        [times addObject:[NSValue valueWithCMTime:currentTime]];
        currentTime = CMTimeAdd(currentTime, interval);
    }
    return [times copy];
}

- (NSArray<NSString *> *)trackingURLsForBoundaryIndex:(NSInteger)index {
    AdPieVideoAdData *videoData = self.adData;
    switch (index) {
        case ADXPlaybackBoundary25:
            ADXDebugLog(@"AdPieRewardedAdViewController First");
            return videoData.trackingFirstQuartileUrls;
        case ADXPlaybackBoundary50:
            ADXDebugLog(@"AdPieRewardedAdViewController Second");
            return videoData.trackingMidpointUrls;
        case ADXPlaybackBoundary75:
            ADXDebugLog(@"AdPieRewardedAdViewController Third");
            return videoData.trackingThirdQuartileUrls;
        case ADXPlaybackBoundary100:
            ADXDebugLog(@"AdPieRewardedAdViewController Complete");
            return videoData.trackingCompleteUrls;
        default: return @[];
    }
}


#pragma mark - Button Action

- (void)endCardImageViewTapped {
    ADXDebugLog(@"endCardImageViewTapped");
    /// Sends Click Tracking URLs
    NSArray<NSString *> * clickUrlArray = [self.adData trackClickURLs];
    if([clickUrlArray count] && self.isClicked == NO) {
        ADXDebugLog(@"clickTrackers");
        self.clicked = YES;
        [self sendTrackingUrl:clickUrlArray];
    }
    /// Sends End-Card Click Tracking URLs
    NSArray<NSString *> * clickTrackingArray = [[self.adData endCard] clickTracking];
    if([clickTrackingArray count] && self.isClickedForEndCard == NO) {
        ADXDebugLog(@"end-card clickTracking");
        self.isClickedForEndCard = YES;
        [self sendTrackingUrl: clickTrackingArray];
    }
    /// End-Card Landing URL
    NSString * landingURL = [[self.adData endCard] clickThrough];
    if([landingURL length]) {
        [self openURLWithString:landingURL];
        /// Fire Click Event
        [self fireDidClickEvent];
    }
}

- (void)clickLink {
    ADXDebugLog(@"clickLink");
    if(self.clicked == NO) {
        /// Click Tracker
        self.clicked = YES;
        [self sendTrackingUrl:self.adData.trackClickURLs];
    }
    
    if (self.adData.link != nil && self.adData.link.length > 0) {
        [self openURLWithString:self.adData.link];
    }
    
    /// Fire Click Event
    [self fireDidClickEvent];
}

- (void)fireDidClickEvent {
    // 매체에 클릭 알림
    if ([self.delegate respondsToSelector:@selector(rewardedAdDidClick)]) {
        [self.delegate rewardedAdDidClick];
    }
}

- (void)changeVolume {
    ADXDebugLog(@"changeVolume");
    
    if (self.volumeButton && self.player) {
        if (self.isMuted) {
            UIImage *volumeOffImage = ADXDecodedBase64ToEncodedString(ADXVolumeOffIconEncodedImage);
            [self.volumeButton setImage:volumeOffImage forState:UIControlStateNormal];
            
        } else {
            UIImage *volumeOnImage = ADXDecodedBase64ToEncodedString(ADXVolumeOnIconEncodedImage);
            [self.volumeButton setImage:volumeOnImage forState:UIControlStateNormal];
        }
        
        self.muted = !self.isMuted;
        
        [self.player setMuted:self.isMuted];
    }
}

- (void)optoutButtonPressed {
    ADXDebugLog(@"optoutButtonPressed");
    [self openURLWithString:self.adData.optoutLinkURL];
}

- (void)skipButtonPressed {
    ADXDebugLog(@"skipButtonPressed");
    /// End-Card Impression
    ADXDebugLog(@"End Card Impression");
    NSArray<NSString *> * impUrlArray = [[self.adData endCard] creativeView];
    [self sendTrackingUrl:impUrlArray];
    
    /// UI View 화면 처리
    if(self.player != nil) {
        [self.player pause];
    }
    
    if([self.playerLayer superlayer]) {
        [self.playerLayer removeFromSuperlayer];
    }
    
    self.closeButton.hidden = NO;
    self.skipButton.hidden = !(self.closeButton.hidden);
    self.volumeButton.hidden = YES;
    self.thumnailImageView.hidden = YES;
    self.endCardImageView.hidden = NO;
}

- (void)closeAd {
    ADXDebugLog(@"closeAd");
    if (self.isSentComplete && [self.delegate respondsToSelector:@selector(rewardedAdDidEarnReward)]) {
        [self.delegate rewardedAdDidEarnReward];
    }
    
    // 매체에 종료 예정 알림
    if ([self.delegate respondsToSelector:@selector(rewardedAdWillDismissScreen)]) {
        [self.delegate rewardedAdWillDismissScreen];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        // 매체에 종료 완료 알림
        if ([weakSelf.delegate respondsToSelector:@selector(rewardedAdDidDismissScreen)]) {
            [weakSelf.delegate rewardedAdDidDismissScreen];
        }
    }];
}

- (void)openURLWithString:(NSString *)urlString {
    if(![urlString length]) {
        return;
    }
    NSURL *url = [NSURL URLWithString:urlString];
    if(!url) {
        return;
    }
    // iOS 10 이상
    if (@available(iOS 10, *)) {
        UIApplication *application = [UIApplication sharedApplication];
        [application openURL:url options:@{} completionHandler:^(BOOL success) {}];
        return;
    }
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] openURL:url];
    #pragma clang diagnostic pop
}

#pragma mark - Public methods

- (BOOL)loadAdWithData:(AdPieVideoAdData *)adData {
    
    BOOL isError = (adData == nil) ? YES : NO;
    
    if (adData.icType != AdPieAdContentTypeRewardedVideo &&
        adData.icType != AdPieAdContentTypeInterstitialIVideo){
        isError = YES;
    }
    
    if(isError) {
        if ([self.delegate respondsToSelector:@selector(rewardedAdDidFailToLoadWithError:)]) {
            [self.delegate rewardedAdDidFailToLoadWithError:[NSError errorWithCode:ADXAdErrorServerData]];
        }
        return NO;
    }
    
    self.adData = adData;
    
    if ([self.delegate respondsToSelector:@selector(rewardedAdDidLoad)]) {
        [self.delegate rewardedAdDidLoad];
    }
    
    return YES;
}

- (void)show {
    if ([self.delegate respondsToSelector:@selector(rewardedAdWillPresentScreen)]) {
        [self.delegate rewardedAdWillPresentScreen];
    }
}

@end
