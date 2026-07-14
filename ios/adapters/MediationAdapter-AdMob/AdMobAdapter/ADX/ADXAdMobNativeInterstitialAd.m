//
//  ADXAdMobNativeInterstitialAd.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "ADXAdMobNativeInterstitialAd.h"

#import "ADXAdMobAdapter.h"
#import <ADXLibrary/ADXNativeAd.h>
#import <ADXLibrary/ADXNativeInterstitialAdView.h>
#import <ADXLibrary/ADXNativeInterstitialAdViewController.h>
#import <ADXLibrary/UIView+ADXAdditions.h>

@interface ADXAdMobNativeInterstitialAd() <GADNativeAdLoaderDelegate, GADNativeAdDelegate, ADXNativeInterstitialAdViewControllerDelegate>

@property (weak) ADXMediationData *adxMediationData;
@property (nonatomic, strong) GADAdLoader *adLoader;
@property (nonatomic, strong) GADNativeAd *nativeAd;

@property (nonatomic, strong) ADXNativeInterstitialAdViewController *adViewController;

@property (nonatomic, assign) BOOL adLoaded;

@end

@implementation ADXAdMobNativeInterstitialAd

@synthesize delegate;
@synthesize adNetworkInfo;

- (BOOL)isLoaded {
    return self.adLoaded && self.nativeAd && self.adViewController;
}

- (void)loadAdWithMediationData:(ADXMediationData *)mediation {
    ADXDebugLog(@"loadAdWithMediationData");
    self.adLoaded = NO;
    
    if (mediation == nil || mediation.customEventParams == nil) {
        NSError *error = [NSError errorWithDomain:ADXAdMobErrorDomain code:ADXAdErrorNoMediationData];
        ADXDebugLogError(@"%@", error.description);
        
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        
        return;
    }
    
    self.adxMediationData = mediation;
    [ADXAdMobAdapter initializeSdkWithConfiguration:nil];
    
    NSString *adUnitId = [mediation.customEventParams objectForKey:@"adunit_id"];
    [self requestAdWithAdUnitId:adUnitId];
}

- (void)requestAdWithAdUnitId:(NSString *)adUnitId {
    if (adUnitId == nil || adUnitId.length == 0) {
        NSError *error = [NSError errorWithDomain:ADXAdMobErrorDomain code:ADXAdErrorServerData description:@"Ad Unit ID cannot be nil."];
        ADXDebugLogError(@"%@", error.description);
        self.adLoaded = NO;
        
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        
        return;
    }
    
    ADXLogDebug(@"requestAd Ad Unit ID - %@", adUnitId);
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIViewController *rootViewController = window.rootViewController;
    while (rootViewController.presentedViewController) {
        rootViewController = rootViewController.presentedViewController;
    }
    
    GADRequest *request = [ADXAdMobAdapter gdprGADRequest];
    
    GADNativeAdImageAdLoaderOptions *nativeAdImageLoaderOptions = [[GADNativeAdImageAdLoaderOptions alloc] init];
    nativeAdImageLoaderOptions.shouldRequestMultipleImages = NO;
    
    self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:adUnitId
                                       rootViewController:rootViewController
                                                  adTypes:@[ GADAdLoaderAdTypeNative ]
                                                  options:@[ nativeAdImageLoaderOptions ]];
    self.adLoader.delegate = self;
    [self.adLoader loadRequest:request];
}

- (void)showAdFromRootViewController:(UIViewController *)rootViewController {
    if (self.isLoaded) {
        [rootViewController presentViewController:self.adViewController animated:YES completion:nil];
    }
}

- (void)dealloc {
    ADXDebugLog(@"dealloc");
    if (self.nativeAd) {
        self.nativeAd.delegate = nil;
        self.nativeAd = nil;
    }
    
    self.adViewController = nil;
    self.delegate = nil;
}

#pragma mark - GADNativeAdLoaderDelegate

- (void)adLoader:(nonnull GADAdLoader *)adLoader didReceiveNativeAd:(nonnull GADNativeAd *)nativeAd {
    ADXLogDebug(@"adLoader:didReceiveNativeAd");
    
    if (!self.adLoaded) {
        if (![self isValidNativeAd:nativeAd]) {
            NSError *error = [NSError errorWithDomain:ADXAdMobErrorDomain code:ADXAdErrorInvalidLayout description:@"Native Interstitial ad is missing one or more required assets, failing the request"];
            ADXDebugLogError(@"%@", error.description);
            self.adLoaded = NO;
            
            if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
                [self.delegate didFailToLoadAdWithError:error];
            }
            
            return;
        }
        
        __weak typeof(self) weakSelf = self;
        nativeAd.paidEventHandler = ^(GADAdValue * _Nonnull value) {
            __typeof__(self) strongSelf = weakSelf;
            if(!strongSelf) {
                ADXDebugLog(@"admob, paidEventHandler, strongSelf is nil");
                return;
            }
            if(![strongSelf adxMediationData]) {
                ADXDebugLog(@"admob, paidEventHandler, MediationData is nil");
                return;
            }
            // Extract the impression-level ad revenue data.
            ADXDebugLog(@"admob, paidEventHandler, ecpm: %f (%d)", [value.value doubleValue] * 1000, value.precision);
            double revenue = [value.value doubleValue] >= 0 ? [value.value doubleValue] * 1000 : strongSelf.adxMediationData.ecpm;
            if ([strongSelf.delegate respondsToSelector:@selector(didPaidEvent:)]) {
                [strongSelf.delegate didPaidEvent:revenue];
            }
        };
        
        self.adLoaded = YES;
        self.nativeAd = nativeAd;
        self.nativeAd.delegate = self;
        
        self.adViewController = [[ADXNativeInterstitialAdViewController alloc] init];
        self.adViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        self.adViewController.delegate = self;
        self.adViewController.adContentView = [self renderingView];
         
        if ([self.delegate respondsToSelector:@selector(didLoadAd)]) {
            [self.delegate didLoadAd];;
        }
    }
}

- (void)adLoader:(nonnull GADAdLoader *)adLoader didFailToReceiveAdWithError:(nonnull NSError *)error {
    ADXLogError(@"adLoader:didFailToReceiveAdWithError: %@", error.description);
    self.adLoaded = NO;
    
    if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
        [self.delegate didFailToLoadAdWithError:[NSError errorWithDomain:ADXAdMobErrorDomain code:ADXAdErrorNoFill]];
    }
}


#pragma mark - GADNativeAdDelegate

- (void)nativeAdDidRecordImpression:(GADNativeAd *)nativeAd {
    ADXLogDebug(@"nativeAdDidRecordImpression");
    [ADXAdMobAdapter printAdNetworkResponseInfo:[nativeAd responseInfo]];
    if ([self.delegate respondsToSelector:@selector(willPresentScreen)]) {
        [self.delegate willPresentScreen];
    }
}

- (void)nativeAdDidRecordClick:(GADNativeAd *)nativeAd {
    ADXLogDebug(@"nativeAdDidRecordClick");
    
    if ([self.delegate respondsToSelector:@selector(didClickAd)]) {
        [self.delegate didClickAd];
    }
}

#pragma mark - ADXNativeInterstitialAdViewControllerDelegate

- (void)nativeInterstitialAdWillDismissScreen {
    ADXLogDebug(@"nativeInterstitialAdWillDismissScreen");
    
    if ([self.delegate respondsToSelector:@selector(willDismissScreen)]) {
        [self.delegate willDismissScreen];
    }
}

- (void)nativeInterstitialAdDidDismissScreen {
    ADXLogDebug(@"nativeInterstitialAdDidDismissScreen");
    self.adLoaded = NO;
    
    if ([self.delegate respondsToSelector:@selector(didDismissScreen)]) {
        [self.delegate didDismissScreen];
    }
}


#pragma mark - Private Methods

- (BOOL)isValidNativeAd:(GADNativeAd *)nativeAd {
    return (nativeAd.headline && nativeAd.body && nativeAd.icon && nativeAd.callToAction);
}

- (UIView *)renderingView {
    ADXNativeInterstitialAdView *adView = [[ADXNativeInterstitialAdView alloc] init];
    adView.translatesAutoresizingMaskIntoConstraints = NO;
    
    GADNativeAdView *nativeAdView = [[GADNativeAdView alloc] init];
    
    GADAdChoicesView *adChoicesView = [[GADAdChoicesView alloc] initWithFrame:CGRectZero];
    adChoicesView.userInteractionEnabled = NO;
    [nativeAdView addSubview:adChoicesView];
    nativeAdView.adChoicesView = adChoicesView;
    
    GADMediaView *mediaView = [[GADMediaView alloc] initWithFrame:CGRectZero];
    [nativeAdView addSubview:mediaView];
    nativeAdView.mediaView = mediaView;
    
    UILabel *headlineView = [[UILabel alloc] initWithFrame:CGRectZero];
    headlineView.text = self.nativeAd.headline;
    headlineView.textColor = [UIColor clearColor];
    [nativeAdView addSubview:headlineView];
    nativeAdView.headlineView = headlineView;
    
    UILabel *bodyView = [[UILabel alloc] initWithFrame:CGRectZero];
    bodyView.text = self.nativeAd.body;
    bodyView.textColor = [UIColor clearColor];
    [nativeAdView addSubview:bodyView];
    nativeAdView.bodyView = bodyView;
    
    UIButton *callToActionView = [[UIButton alloc] initWithFrame:CGRectZero];
    [callToActionView setTitle:self.nativeAd.callToAction forState:UIControlStateNormal];
    [callToActionView setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [nativeAdView addSubview:callToActionView];
    nativeAdView.callToActionView = callToActionView;
    
    UIImageView *mainMediaImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    mainMediaImageView.image = self.nativeAd.images.firstObject.image;
    [nativeAdView addSubview:mainMediaImageView];
    nativeAdView.imageView = mainMediaImageView;
    
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
    iconView.image = self.nativeAd.icon.image;
    [nativeAdView addSubview:iconView];
    nativeAdView.iconView = iconView;
    
    nativeAdView.nativeAd = self.nativeAd;
    [nativeAdView addSubview:adView];
    [adView fillSuperview];
    
    if ([adView respondsToSelector:@selector(nativeTitleTextLabel)] && adView.nativeTitleTextLabel) {
        [adView.nativeTitleTextLabel addSubview:nativeAdView.headlineView];
        adView.nativeTitleTextLabel.text = self.nativeAd.headline;
        [nativeAdView.headlineView fillSuperview];
    }
    
    if ([adView respondsToSelector:@selector(nativeMainTextLabel)] && adView.nativeMainTextLabel) {
        [adView.nativeMainTextLabel addSubview:nativeAdView.bodyView];
        adView.nativeMainTextLabel.text = self.nativeAd.body;
        [nativeAdView.bodyView fillSuperview];
    }
    
    if ([adView respondsToSelector:@selector(nativeCallToActionButton)] && adView.nativeCallToActionButton) {
        nativeAdView.callToActionView.userInteractionEnabled = YES;
        [adView.nativeCallToActionButton addSubview:nativeAdView.callToActionView];
        [adView.nativeCallToActionButton setTitle:self.nativeAd.callToAction forState:UIControlStateNormal];
        adView.nativeCallToActionButton.userInteractionEnabled = NO;
        [nativeAdView.callToActionView fillSuperview];
    }
    
    if ([adView respondsToSelector:@selector(nativeIconImageView)] && adView.nativeIconImageView) {
        [adView.nativeIconImageView addSubview:nativeAdView.iconView];
        [nativeAdView.iconView fillSuperview];
    }
    
    if ([adView respondsToSelector:@selector(nativePrivacyInformationIconImageView)] && adView.nativePrivacyInformationIconImageView) {
        [adView.nativePrivacyInformationIconImageView addSubview:nativeAdView.adChoicesView];
        [nativeAdView.adChoicesView fillSuperview];
    }
    
    if ([adView respondsToSelector:@selector(nativeMainImageView)] && adView.nativeMainImageView) {
        [adView.nativeMainImageView addSubview:nativeAdView.mediaView];
        [nativeAdView.mediaView fillSuperview];
        
        adView.nativeMainImageView.userInteractionEnabled = YES;
    }
    
    return nativeAdView;
}

@end
