//
//  AppLovinAdPieAdapter.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "AppLovinAdPieAdapter.h"

#import <AdPieSDK/AdPieSDK.h>

#import "AdPieNativeAdView.h"
#import <ADXLibrary/ADXAdLogEvent.h>
#import <ADXLibrary/ADXAdError.h>
#import <ADXLibrary/ADXImageDownloadQueue.h>
#import "ADXAdPieAdapter.h"

@interface AppLovinAdPieAdapterAdViewAdDelegate : NSObject<APAdViewDelegate>

@property (weak) AppLovinAdPieAdapter *parentAdapter;
@property (strong) id<MAAdViewAdapterDelegate> delegate;

- (instancetype)initWithParentAdapter:(AppLovinAdPieAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;

@end

@interface AppLovinAdPieAdapterInterstitialAdDelegate : NSObject<APInterstitialDelegate>

@property (weak) AppLovinAdPieAdapter *parentAdapter;
@property (strong) id<MAInterstitialAdapterDelegate> delegate;

- (instancetype)initWithParentAdapter:(AppLovinAdPieAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;

@end

@interface AppLovinAdPieAdapterRewardedAdDelegate : NSObject<APRewardedAdDelegate>

@property (weak) AppLovinAdPieAdapter *parentAdapter;
@property (strong) id<MARewardedAdapterDelegate> delegate;

- (instancetype)initWithParentAdapter:(AppLovinAdPieAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;

@end

@interface AppLovinAdPieAdapterNativeAdDelegate : NSObject<APNativeDelegate, AdPieNativeAdViewDelegate>

@property (weak) AppLovinAdPieAdapter *parentAdapter;
@property (strong) NSDictionary<NSString *, id> *serverParameters;
@property (strong) id<MANativeAdAdapterDelegate> delegate;

@property (assign, getter=isReportedImpression) BOOL reportedImpression;
@property (strong) ADXImageDownloadQueue *imageDownloadQueue;
@property (strong) NSDictionary *imageDictionary;

- (instancetype)initWithParentAdapter:(AppLovinAdPieAdapter *)parentAdapter serverParameters:(NSDictionary<NSString *, id> *)serverParameters andNotify:(id<MANativeAdAdapterDelegate>)delegate;

@end

@interface MAAdPieNativeAd : MANativeAd

@property (weak) AppLovinAdPieAdapter *parentAdapter;

- (instancetype)initWithParentAdapter:(AppLovinAdPieAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock;
- (instancetype)initWithFormat:(MAAdFormat *)format builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock NS_UNAVAILABLE;

@end

@interface AppLovinAdPieAdapter ()

@property (strong) APAdView *adView;
@property (strong) AppLovinAdPieAdapterAdViewAdDelegate *adViewAdDelegate;

@property (strong) APNativeAd *nativeAd;
@property (strong) AdPieNativeAdView *nativeAdView;
@property (strong) AppLovinAdPieAdapterNativeAdDelegate *nativeAdDelegate;

@property (strong) APInterstitial *interstitialAd;
@property (strong) AppLovinAdPieAdapterInterstitialAdDelegate *interstitialAdDelegate;

@property (strong) APRewardedAd *rewardedAd;
@property (strong) AppLovinAdPieAdapterRewardedAdDelegate *rewardedAdDelegate;

@end

@implementation AppLovinAdPieAdapter

static ALAtomicBoolean *ALAdPieInitialized;
static MAAdapterInitializationStatus ALAdPieInitializationStatus = NSIntegerMin;

+ (void)initialize
{
    [super initialize];
    ALAdPieInitialized = [[ALAtomicBoolean alloc] init];
}

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler {
    if ([ALAdPieInitialized compareAndSet:NO update:YES]) {
        ALAdPieInitializationStatus = MAAdapterInitializationStatusInitializing;
        
        NSDictionary<NSString *, id> *serverParameters = parameters.serverParameters;
        NSString *appId = [serverParameters al_stringForKey:@"app_id"];
        
        [ADXAdPieAdapter initializeAdPieSdk:appId completion:^(BOOL initialized, NSError *error) {
            if (initialized) {
                ALAdPieInitializationStatus = MAAdapterInitializationStatusInitializedSuccess;
                completionHandler(ALAdPieInitializationStatus, nil);
            } else {
                ALAdPieInitializationStatus = MAAdapterInitializationStatusInitializedFailure;
                completionHandler(ALAdPieInitializationStatus, @"AdPie SDK failed to initialized. The media id is empty");
            }
        }];
        
    } else {
        ADXLogDebug(@"AdPie SDK already initialized");
        completionHandler(ALAdPieInitializationStatus, nil);
    }
}

- (NSString *)SDKVersion {
    return [AdPieSDK sdkVersion];
}

- (NSString *)adapterVersion {
    return [NSString stringWithFormat:@"%@.0", [AdPieSDK sdkVersion]];
}

- (void)destroy {
    self.adView = nil;
    self.adViewAdDelegate = nil;
    
    self.interstitialAd = nil;
    self.interstitialAdDelegate = nil;
    
    self.rewardedAd = nil;
    self.rewardedAdDelegate = nil;
    
    self.nativeAd = nil;
    self.nativeAdDelegate =nil;
    [self.nativeAdView removeFromSuperview];
    self.nativeAdView = nil;
}

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegate {
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeBanner, ADXAdEventLoad);
    
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *floorPrice = parameters.customParameters[@"floor_price"];
    UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    CGSize size = [self sizeFromAdFormat:adFormat];
    
    self.adViewAdDelegate = [[AppLovinAdPieAdapterAdViewAdDelegate alloc] initWithParentAdapter:self andNotify:delegate];
    
    self.adView = [[APAdView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    self.adView.slotId = slotId;
    self.adView.delegate = self.adViewAdDelegate;
    self.adView.rootViewController = presentingViewController;
    if (floorPrice != nil) {
        [self.adView setExtraParameterForKey:@"floorPrice" value:floorPrice];
    }
    [self.adView load];
}

- (void)loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate {
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *floorPrice = parameters.customParameters[@"floor_price"];
    
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeInterstitial, ADXAdEventLoad);
    ADXLogDebug(@"Interstitial ad load - %@", slotId);
    
    self.interstitialAdDelegate = [[AppLovinAdPieAdapterInterstitialAdDelegate alloc] initWithParentAdapter:self andNotify:delegate];
    
    self.interstitialAd = [[APInterstitial alloc] initWithSlotId:slotId];
    self.interstitialAd.delegate = self.interstitialAdDelegate;
    if (floorPrice != nil) {
        [self.interstitialAd setExtraParameterForKey:@"floorPrice" value:floorPrice];
    }
    [self.interstitialAd load];
}

- (void)showInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MAInterstitialAdapterDelegate>)delegate {
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeInterstitial, ADXAdEventShow);
    
    UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    [self.interstitialAd presentFromRootViewController:presentingViewController];
}

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate {
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *floorPrice = parameters.customParameters[@"floor_price"];
    
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdEventReward, ADXAdEventLoad);
    ADXLogDebug(@"Rewarded ad load - %@", slotId);
    
    self.rewardedAdDelegate = [[AppLovinAdPieAdapterRewardedAdDelegate alloc] initWithParentAdapter:self andNotify:delegate];
    
    self.rewardedAd = [[APRewardedAd alloc] initWithSlotId:slotId];
    self.rewardedAd.delegate = self.rewardedAdDelegate;
    if (floorPrice != nil) {
        [self.rewardedAd setExtraParameterForKey:@"floorPrice" value:floorPrice];
    }
    [self.rewardedAd load];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate {
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdEventReward, ADXAdEventShow);
    
    UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    [self.rewardedAd presentFromRootViewController:presentingViewController];
}

- (void)loadNativeAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MANativeAdAdapterDelegate>)delegate {
    NSString *slotId = parameters.thirdPartyAdPlacementIdentifier;
    NSString *floorPrice = parameters.customParameters[@"floor_price"];
    
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeNative, ADXAdEventLoad);
    ADXLogDebug(@"Native ad load - %@", slotId);
    
    self.nativeAdDelegate = [[AppLovinAdPieAdapterNativeAdDelegate alloc] initWithParentAdapter:self serverParameters:parameters.serverParameters andNotify:delegate];
    
    self.nativeAd = [[APNativeAd alloc] initWithSlotId:slotId];
    self.nativeAd.delegate = self.nativeAdDelegate;
    if (floorPrice != nil) {
        [self.nativeAd setExtraParameterForKey:@"floorPrice" value:floorPrice];
    }
    [self.nativeAd load];
}


#pragma mark - Helper Methods

- (CGSize)sizeFromAdFormat:(MAAdFormat *)adFormat {
    if (adFormat == MAAdFormat.banner) {
        return CGSizeMake(320, 50);
        
    } else if (adFormat == MAAdFormat.mrec) {
        return CGSizeMake(300, 250);
        
    } else {
        [NSException raise: NSInvalidArgumentException format: @"Unsupported ad format: %@", adFormat];
        return CGSizeZero;
    }
}

@end


@implementation AppLovinAdPieAdapterAdViewAdDelegate

- (instancetype)initWithParentAdapter:(AppLovinAdPieAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate {
    self = [super init];
    
    if (self) {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    
    return self;
}


#pragma mark - APAdViewDelegate

- (void)adViewDidLoadAd:(APAdView *)view {
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeBanner, ADXAdEventLoaded);
    ADXDebugLog(@"Banner ad loaded: %@", view.slotId);
    
    [self.delegate didLoadAdForAdView:view];
}

- (void)adViewDidFailToLoadAd:(APAdView *)view withError:(NSError *)error {
    ADXLogEventError(ADXAdNetworkAdPie, ADXAdTypeBanner, ADXAdEventLoadFailed, error);
    ADXDebugLogError(@"Banner ad (%@) failed to load with error: %@", view.slotId, error);
    
    MAAdapterError *adapterError = [MAAdapterError errorWithCode:error.code errorString:error.description];
    [self.delegate didFailToLoadAdViewAdWithError:adapterError];
}

- (void)adViewWillLeaveApplication:(APAdView *)view {
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeBanner, ADXAdEventClick);
    ADXDebugLog(@"Banner ad clicked: %@", view.slotId);
    
    [self.delegate didClickAdViewAd];
}

@end


@implementation AppLovinAdPieAdapterInterstitialAdDelegate

- (instancetype)initWithParentAdapter:(AppLovinAdPieAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate {
    self = [super init];
    
    if (self) {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    
    return self;
}

#pragma mark - APInterstitialDelegate

- (void)interstitialDidLoadAd:(APInterstitial *)interstitial {
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeInterstitial, ADXAdEventLoaded);
    ADXDebugLog(@"Interstitial ad loaded: %@", interstitial.slotId);
    
    [self.delegate didLoadInterstitialAd];
}

- (void)interstitialDidFailToLoadAd:(APInterstitial *)interstitial withError:(NSError *)error {
    ADXLogEventError(ADXAdNetworkAdPie, ADXAdTypeInterstitial, ADXAdEventLoadFailed, error);
    ADXLogError(@"Interstitial ad (%@) failed to load with error: %@", interstitial.slotId, error);
    
    MAAdapterError *adapterError = [MAAdapterError errorWithCode:error.code errorString:error.description];
    [self.delegate didFailToLoadInterstitialAdWithError:adapterError];
}

- (void)interstitialWillPresentScreen:(APInterstitial *)interstitial {
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeInterstitial, ADXAdEventShown);
    ADXLogDebug(@"Interstitial ad shown: %@", interstitial.slotId);
    
    [self.delegate didDisplayInterstitialAd];
}

- (void)interstitialDidDismissScreen:(APInterstitial *)interstitial {
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeInterstitial, ADXAdEventClose);
    ADXLogDebug(@"Interstitial ad close: %@", interstitial.slotId);
    
    [self.delegate didHideInterstitialAd];
}

- (void)interstitialWillLeaveApplication:(APInterstitial *)interstitial {
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeInterstitial, ADXAdEventClick);
    ADXLogDebug(@"Interstitial ad clicked: %@", interstitial.slotId);
    
    [self.delegate didClickInterstitialAd];
}

@end


@implementation AppLovinAdPieAdapterRewardedAdDelegate

- (instancetype)initWithParentAdapter:(AppLovinAdPieAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate {
    self = [super init];
    
    if (self) {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    
    return self;
}

#pragma mark - APRewardedAdDelegate

- (void)rewardedAdDidLoadAd:(APRewardedAd *)rewardedAd {
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeRewarded, ADXAdEventLoaded);
    ADXLogDebug(@"Rewarded ad loaded: %@", rewardedAd.slotId);
    
    [self.delegate didLoadRewardedAd];
}

- (void)rewardedAdDidFailToLoadAd:(APRewardedAd *)rewardedAd withError:(NSError *)error {
    ADXLogEventError(ADXAdNetworkAdPie, ADXAdTypeRewarded, ADXAdEventLoadFailed, error);
    ADXLogError(@"Rewarded ad (%@) failed to load with error: %@", rewardedAd.slotId, error);
    
    MAAdapterError *adapterError = [MAAdapterError errorWithCode:error.code errorString:error.description];
    [self.delegate didFailToLoadRewardedAdWithError:adapterError];
}

- (void)rewardedAdWillPresentScreen:(APRewardedAd *)rewardedAd {
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeRewarded, ADXAdEventShown);
    ADXLogDebug(@"Rewarded ad shown: %@", rewardedAd.slotId);
    
    [self.delegate didDisplayRewardedAd];
}

- (void)rewardedAdDidDismissScreen:(APRewardedAd *)rewardedAd {
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeRewarded, ADXAdEventClose);
    ADXLogDebug(@"Rewarded ad close: %@", rewardedAd.slotId);
    
    [self.delegate didHideRewardedAd];
}

- (void)rewardedAdWillLeaveApplication:(APRewardedAd *)rewardedAd {
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeRewarded, ADXAdEventClick);
    ADXLogDebug(@"Rewarded ad clicked: %@", rewardedAd.slotId);
    
    [self.delegate didClickRewardedAd];
}

- (void)rewardedAdDidEarnReward:(APRewardedAd *)rewardedAd {
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeRewarded, ADXAdEventReward);
    ADXLogDebug(@"Rewarded ad user with reward: %@", rewardedAd.slotId);
    
    MAReward *maxReward = [self.parentAdapter reward];
    [self.delegate didRewardUserWithReward:maxReward];
}

@end


@implementation AppLovinAdPieAdapterNativeAdDelegate

- (instancetype)initWithParentAdapter:(AppLovinAdPieAdapter *)parentAdapter serverParameters:(NSDictionary<NSString *,id> *)serverParameters andNotify:(id<MANativeAdAdapterDelegate>)delegate {
    self = [super init];
    
    if (self) {
        self.parentAdapter = parentAdapter;
        self.serverParameters = serverParameters;
        self.delegate = delegate;
    }
    
    return self;
}

#pragma mark - Private Methods

- (BOOL)addURLString:(NSString *)urlString toURLArray:(NSMutableArray *)urlArray {
    if (urlString.length == 0) {
        return NO;
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    if (url) {
        [urlArray addObject:url];
        return YES;
        
    } else {
        return NO;
    }
}

- (void)precacheImagesWithURLs:(NSArray *)imageURLs completionHandler:(void (^)(NSArray * _Nullable))completionHandler {
    if (self.imageDownloadQueue == nil) {
        self.imageDownloadQueue = [[ADXImageDownloadQueue alloc] init];
    }
    
    if (imageURLs.count > 0) {
        __weak typeof(self) weakSelf = self;
        [self.imageDownloadQueue addDownloadImageURLs:imageURLs completionBlock:^(NSDictionary <NSURL *, UIImage *> *result, NSArray *errors) {
            weakSelf.imageDictionary = result;
            
            if (completionHandler) {
                completionHandler(errors);
            }
        }];
    } else {
        if (completionHandler) {
            completionHandler(nil);
        }
    }
}

- (void)renderNativeAdView:(APNativeAd *)nativeAd {
    __weak typeof(self) weakSelf = self;
    dispatchOnMainQueue(^{
        __typeof__(self) strongSelf = weakSelf;
        MANativeAd *maxNativeAd = [[MAAdPieNativeAd alloc] initWithParentAdapter:strongSelf.parentAdapter builderBlock:^(MANativeAdBuilder * _Nonnull builder) {
            __typeof__(self) strongSelf = weakSelf;
            builder.title = nativeAd.nativeAdData.title;
            builder.body = nativeAd.nativeAdData.desc;
            builder.callToAction = nativeAd.nativeAdData.callToAction;
            
            if (nativeAd.nativeAdData.iconImageUrl) {
                NSURL *iconURL = [NSURL URLWithString:nativeAd.nativeAdData.iconImageUrl];
                builder.icon = [[MANativeAdImage alloc] initWithURL:iconURL];
            }
            
            if (nativeAd.nativeAdData.mainImageUrl) {
                NSURL *url = [NSURL URLWithString:nativeAd.nativeAdData.mainImageUrl];
                
                if ([strongSelf.imageDictionary objectForKey:url] != nil) {
                    UIImageView *mainImageView = [[UIImageView alloc] init];
                    [mainImageView setImage:[strongSelf.imageDictionary objectForKey:url]];
                    builder.mediaView = mainImageView;
                }
            }
            
            if (nativeAd.nativeAdData.optoutImageUrl) {
                NSURL *url = [NSURL URLWithString:nativeAd.nativeAdData.optoutImageUrl];
                
                if ([strongSelf.imageDictionary objectForKey:url] != nil) {
                    UIImageView *optoutImageView = [[UIImageView alloc] init];
                    [optoutImageView setImage:[strongSelf.imageDictionary objectForKey:url]];
                    builder.optionsView = optoutImageView;
                }
            }
        }];
        [strongSelf.delegate didLoadAdForNativeAd:maxNativeAd withExtraInfo:nil];
    });
}

#pragma mark - APNativeDelegate

- (void)nativeDidLoadAd:(APNativeAd *)nativeAd {
    [self.parentAdapter log: @"Native ad ad loaded: %@", nativeAd.slotId];
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeNative, ADXAdEventLoaded);
    ADXLogDebug(@"Native ad loaded: %@", nativeAd.slotId);
    
    if (nativeAd.nativeAdData == nil) {
        [self.parentAdapter log: @"Native ad failed to load: AdPie native ad is missing one or more required assets"];
        [self.delegate didFailToLoadNativeAdWithError:MAAdapterError.invalidConfiguration];
        
        return;
    }
    
    NSMutableArray *imageURLs = [NSMutableArray array];
    if (nativeAd.nativeAdData.mainImageUrl != nil) {
        [self addURLString:nativeAd.nativeAdData.mainImageUrl toURLArray:imageURLs];
    }
    
    if (nativeAd.nativeAdData.iconImageUrl != nil) {
        [self addURLString:nativeAd.nativeAdData.iconImageUrl toURLArray:imageURLs];
    }
    
    if (nativeAd.nativeAdData.optoutImageUrl != nil) {
        [self addURLString:nativeAd.nativeAdData.optoutImageUrl toURLArray:imageURLs];
    }
    
    __weak typeof(self) weakSelf = self;
    [self precacheImagesWithURLs:imageURLs completionHandler:^(NSArray * _Nullable errors) {
        if (errors) {
            NSError *error = [NSError errorWithCode:ADXAdErrorContentLoad];
            ADXDebugLogError(@"%@", error.description);
            
            MAAdapterError *adapterError = [MAAdapterError errorWithCode:error.code errorString:error.description];
            [weakSelf.delegate didFailToLoadNativeAdWithError:adapterError];
            
        } else {
            [weakSelf renderNativeAdView:nativeAd];
        }
    }];
}

- (void)nativeDidFailToLoadAd:(APNativeAd *)nativeAd withError:(NSError *)error {
    ADXLogEventError(ADXAdNetworkAdPie, ADXAdTypeNative, ADXAdEventLoadFailed, error);
    ADXLogError(@"Native ad (%@) failed to load with error: %@", nativeAd.slotId, error);
    
    MAAdapterError *adapterError = [MAAdapterError errorWithCode:error.code errorString:error.description];
    [self.delegate didFailToLoadNativeAdWithError:adapterError];
}

- (void)nativeWillLeaveApplication:(APNativeAd *)nativeAd {
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeNative, ADXAdEventClick);
    ADXLogDebug(@"Native ad clicked: %@", nativeAd.slotId);
    
    [self.delegate didClickNativeAd];
}


#pragma mark - AdPieNativeAdViewDelegate

- (void)nativeAdViewTrackImpression:(AdPieNativeAdView *)nativeAdView {
    if (!self.isReportedImpression) {
        self.reportedImpression = YES;
        
        [self.parentAdapter.nativeAd fireImpression];
    }
}

- (void)nativeAdViewDidClick:(AdPieNativeAdView *)nativeAdView {
    [self.parentAdapter.nativeAd invokeDefaultAction];
    [self.parentAdapter.nativeAd.delegate nativeWillLeaveApplication:self.parentAdapter.nativeAd];
}

@end


@implementation MAAdPieNativeAd

- (instancetype)initWithParentAdapter:(AppLovinAdPieAdapter *)parentAdapter builderBlock:(NS_NOESCAPE MANativeAdBuilderBlock)builderBlock {
    self = [super initWithFormat:MAAdFormat.native builderBlock:builderBlock];
    if (self) {
        self.parentAdapter = parentAdapter;
    }
    
    return self;
}


- (void)prepareViewForInteraction:(MANativeAdView *)maxNativeAdView {
    if (!self.parentAdapter.nativeAd) {
        [self.parentAdapter e:@"Failed to register native ad views for interaction: native ad is nil."];
        return;
    }
    
    AdPieNativeAdView *nativeAdView = [[AdPieNativeAdView alloc] init];
    nativeAdView.nativeAd = self.parentAdapter.nativeAd;
    nativeAdView.delegate = self.parentAdapter.nativeAdDelegate;
    
    [maxNativeAdView addSubview:nativeAdView];
    
    NSMutableArray *clickableViews = [NSMutableArray array];
    
    if ([self.title al_isValidString] && maxNativeAdView.titleLabel) {
        [clickableViews addObject: maxNativeAdView.titleLabel];
    }
    
    if ([self.body al_isValidString] && maxNativeAdView.bodyLabel) {
        [clickableViews addObject: maxNativeAdView.bodyLabel];
    }
    
    if ([self.callToAction al_isValidString] && maxNativeAdView.callToActionButton) {
        [clickableViews addObject: maxNativeAdView.callToActionButton];
    }
    
    if (self.icon && maxNativeAdView.iconImageView) {
        [clickableViews addObject: maxNativeAdView.iconImageView];
    }
    
    if (self.mediaView && maxNativeAdView.mediaContentView) {
        [clickableViews addObject: maxNativeAdView.mediaContentView];
    }
    
    if (self.optionsView && maxNativeAdView.optionsContentView) {
        [nativeAdView registerClickablePrivacy:maxNativeAdView.optionsContentView];
    }
    
    if ([maxNativeAdView respondsToSelector: @selector(advertiserLabel)] && [self respondsToSelector: @selector(advertiser)]) {
        id advertiserLabel = [maxNativeAdView performSelector: @selector(advertiserLabel)];
        id advertiser = [self performSelector: @selector(advertiser)];
        if ([advertiser al_isValidString] && advertiserLabel) {
            [nativeAdView registerClickablePrivacy:advertiserLabel];
        }
    }
    
    [nativeAdView registerClickableViews:clickableViews];
    
    self.parentAdapter.nativeAdView = nativeAdView;
}

@end
