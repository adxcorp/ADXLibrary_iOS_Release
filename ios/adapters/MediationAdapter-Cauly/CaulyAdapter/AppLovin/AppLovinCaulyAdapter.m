//
//  AppLovinCaulyAdapter.m
//  ADXLibrary-Cauly
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "AppLovinCaulyAdapter.h"

#import <CaulySDK/Cauly.h>
#import <CaulySDK/CaulyAdView.h>
#import <CaulySDK/CaulyInterstitialAd.h>

#import <ADXLibrary/ADXAdLogEvent.h>

@interface AppLovinCaulyAdapterAdViewAdDelegate: NSObject<CaulyAdViewDelegate>

@property (nonatomic, weak) AppLovinCaulyAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;

- (instancetype)initWithParentAdapter:(AppLovinCaulyAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;

@end

@interface AppLovinCaulyAdapterInterstitialAdDelegate : NSObject<CaulyInterstitialAdDelegate>

@property (weak) AppLovinCaulyAdapter *parentAdapter;
@property (strong) id<MAInterstitialAdapterDelegate> delegate;

- (instancetype)initWithParentAdapter:(AppLovinCaulyAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate;

@end

@interface AppLovinCaulyAdapter () <CaulyAdViewDelegate, CaulyInterstitialAdDelegate>

@property (strong) CaulyAdView *adViewAd;
@property (strong) AppLovinCaulyAdapterAdViewAdDelegate *adViewAdDelegate;

@property (strong) CaulyInterstitialAd *interstitialAd;
@property (strong) AppLovinCaulyAdapterInterstitialAdDelegate *interstitialAdDelegate;

@end

@implementation AppLovinCaulyAdapter

#pragma mark - MAAdapter Methods

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString *_Nullable))completionHandler {
    NSString *appId = [parameters.serverParameters al_stringForKey:@"app_id"];
    
    if (appId == nil) {
        completionHandler(MAAdapterInitializationStatusInitializedFailure, @"Cauly SDK failed to initialized. The appId is empty");
        return;
    }
    
    CaulyAdSetting *adSetting = [CaulyAdSetting globalSetting];
    adSetting.appId = appId; // 앱스토어에 등록된 App ID 정보
    adSetting.animType = CaulyAnimNone;
    adSetting.reloadTime = CaulyReloadTime_0;
    adSetting.useDynamicReloadTime = NO;
    adSetting.closeOnLanding = YES;
    
    ADXLogDebug(@"[CaulyAdapter] adSetting appId = %@", appId);
    
    completionHandler(MAAdapterInitializationStatusDoesNotApply, nil);
}

- (NSString *)SDKVersion {
    return CAULY_SDK_VERSION;
}

- (NSString *)adapterVersion {
    NSString *versionString = [NSString stringWithFormat:@"%@.0", CAULY_SDK_VERSION];
    return versionString;
}

- (void)destroy {
    self.adViewAd = nil;
    self.adViewAdDelegate = nil;
    self.interstitialAd = nil;
    self.interstitialAdDelegate = nil;
}

#pragma mark - MAAdViewAdapter Methods

- (void)loadAdViewAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters adFormat:(nonnull MAAdFormat *)adFormat andNotify:(nonnull id<MAAdViewAdapterDelegate>)delegate {
    ADXLogEvent(ADXAdNetworkCauly, ADXAdTypeBanner, ADXAdEventLoad);
    
    NSString *appCode = parameters.thirdPartyAdPlacementIdentifier;
    
    CaulyAdSetting *adSetting = [CaulyAdSetting globalSetting];
    adSetting.appCode = appCode;

    if (self.adViewAd) {
        [self.adViewAd removeFromSuperview];
        self.adViewAd = nil;
    }
    
    ADXLogInfo(@"[CaulyAdapter] loadAd appCode = %@", appCode);
    
    self.adViewAdDelegate = [[AppLovinCaulyAdapterAdViewAdDelegate alloc] initWithParentAdapter:self andNotify:delegate];
    
    UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    CGSize size = [self sizeFromAdFormat:adFormat];
    
    self.adViewAd = [[CaulyAdView alloc] initWithParentViewController:presentingViewController];
    self.adViewAd.frame = CGRectMake(0, 0, size.width, size.height);
    self.adViewAd.delegate = self.adViewAdDelegate;
    [self.adViewAd startBannerAdRequest];
}

- (void)loadInterstitialAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters andNotify:(nonnull id<MAInterstitialAdapterDelegate>)delegate {
    ADXLogEvent(ADXAdNetworkCauly, ADXAdTypeInterstitial, ADXAdEventLoad);
    
    NSString *appCode = parameters.thirdPartyAdPlacementIdentifier;
    
    CaulyAdSetting *adSetting = [CaulyAdSetting globalSetting];
    adSetting.appCode = appCode;
    
    ADXLogInfo(@"[CaulyAdapter] loadAd appCode = %@", appCode);
    
    self.interstitialAdDelegate = [[AppLovinCaulyAdapterInterstitialAdDelegate alloc] initWithParentAdapter:self andNotify:delegate];
    
    self.interstitialAd = [[CaulyInterstitialAd alloc] init];
    self.interstitialAd.delegate = self.interstitialAdDelegate;
    [self.interstitialAd startInterstitialAdRequest];
}

- (void)showInterstitialAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters andNotify:(nonnull id<MAInterstitialAdapterDelegate>)delegate {
    ADXLogEvent(ADXAdNetworkCauly, ADXAdTypeInterstitial, ADXAdEventShow);
    
    NSString *appCode = parameters.thirdPartyAdPlacementIdentifier;
    [self log: @"Showing interstitial ad: %@...", appCode];
    
    if (self.interstitialAd) {
        UIViewController *presentingViewController = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
        [self.interstitialAd showWithParentViewController:presentingViewController];
        
    } else {
        [self log: @"Interstitial ad failed to show: %@", appCode];
        [delegate didFailToDisplayInterstitialAdWithError: MAAdapterError.adNotReady];
    }
}


#pragma mark - Helper Methods

- (CGSize)sizeFromAdFormat:(MAAdFormat *)adFormat {
    if (adFormat == MAAdFormat.banner) {
        return CGSizeMake(320, 50);
        
    } else if (adFormat == MAAdFormat.leader) {
        return CGSizeMake(728, 90);
        
    } else if (adFormat == MAAdFormat.mrec) {
        return CGSizeMake(300, 250);
        
    } else {
        [NSException raise: NSInvalidArgumentException format: @"Unsupported ad format: %@", adFormat];
        return CGSizeZero;
    }
}

+ (MAAdapterError *)toMaxErrorCode:(int)errorCode errorMsg:(NSString *)errorMsg {
    MAAdapterError *adapterError = MAAdapterError.unspecified;
    switch (errorCode)
    {
        case CaulyError_NO_FILL_AD:
            adapterError = MAAdapterError.noFill;
            break;
            
        case CaulyError_INVAILD_APP_CODE:
            adapterError = MAAdapterError.notInitialized;
            break;
            
        case CaulyError_SERVER_ERROR:
            adapterError = MAAdapterError.serverError;
            break;
            
        case CaulyError_SDK_INNER_ERROR:
            adapterError = MAAdapterError.internalError;
            break;
            
        default:
            adapterError = MAAdapterError.internalError;
            break;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MAAdapterError errorWithCode: adapterError.errorCode
                             errorString: adapterError.errorMessage
                  thirdPartySdkErrorCode: errorCode
               thirdPartySdkErrorMessage: errorMsg];
#pragma clang diagnostic pop
}

@end

@implementation AppLovinCaulyAdapterAdViewAdDelegate

- (instancetype)initWithParentAdapter:(AppLovinCaulyAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate {
    self = [super init];
    
    if (self) {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    
    return self;
}

#pragma mark - CaulyAdViewDelegate

- (void)didReceiveAd:(CaulyAdView *)adView isChargeableAd:(BOOL)isChargeableAd {
    ADXLogEvent(ADXAdNetworkCauly, ADXAdTypeBanner, ADXAdEventLoaded);
    
    [self.delegate didLoadAdForAdView:adView];
}

- (void)didFailToReceiveAd:(CaulyAdView *)adView errorCode:(int)errorCode errorMsg:(NSString *)errorMsg {
    ADXLogEventError(ADXAdNetworkCauly, ADXAdTypeBanner, ADXAdEventLoadFailed, errorMsg);
    
    MAAdapterError *adapterError = [AppLovinCaulyAdapter toMaxErrorCode:errorCode errorMsg:errorMsg];
    [self.parentAdapter log: @"Banner ad (%@) failed to load with error: %@", [CaulyAdSetting globalSetting].appCode, adapterError];
    [self.delegate didFailToLoadAdViewAdWithError: adapterError];
}

- (void)willShowLandingView:(CaulyAdView *)adView {
    ADXLogEvent(ADXAdNetworkCauly, ADXAdTypeBanner, ADXAdEventShown);
    
    [self.delegate didDisplayAdViewAd];
}

@end


@implementation AppLovinCaulyAdapterInterstitialAdDelegate

- (instancetype)initWithParentAdapter:(AppLovinCaulyAdapter *)parentAdapter andNotify:(id<MAInterstitialAdapterDelegate>)delegate {
    self = [super init];
    
    if (self) {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    
    return self;
}

#pragma mark - CaulyInterstitialAdDelegate

- (void)didReceiveInterstitialAd:(CaulyInterstitialAd *)interstitialAd isChargeableAd:(BOOL)isChargeableAd {
    ADXLogEvent(ADXAdNetworkCauly, ADXAdTypeInterstitial, ADXAdEventLoaded);
    
    [self.delegate didLoadInterstitialAd];
}

- (void)didFailToReceiveInterstitialAd:(CaulyInterstitialAd *)interstitialAd errorCode:(int)errorCode errorMsg:(NSString *)errorMsg {
    ADXLogEventError(ADXAdNetworkCauly, ADXAdTypeInterstitial, ADXAdEventLoadFailed, errorMsg);
    
    MAAdapterError *adapterError = [AppLovinCaulyAdapter toMaxErrorCode:errorCode errorMsg:errorMsg];
    [self.delegate didFailToLoadInterstitialAdWithError:adapterError];
}

- (void)willShowInterstitialAd:(CaulyInterstitialAd *)interstitialAd {
    ADXLogEvent(ADXAdNetworkCauly, ADXAdTypeInterstitial, ADXAdEventShown);
    
    [self.delegate didDisplayInterstitialAd];
}

- (void)didCloseInterstitialAd:(CaulyInterstitialAd *)interstitialAd {
    ADXLogEvent(ADXAdNetworkCauly, ADXAdTypeInterstitial, ADXAdEventClose);
    
    [self.delegate didHideInterstitialAd];
}

@end
