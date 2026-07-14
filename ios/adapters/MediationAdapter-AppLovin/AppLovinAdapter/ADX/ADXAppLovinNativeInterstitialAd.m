//
//  ADXAppLovinNativeInterstitialAd.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "ADXAppLovinNativeInterstitialAd.h"

#import "ADXAppLovinAdapter.h"
#import <ADXLibrary/ADXNativeAd.h>
#import <ADXLibrary/ADXNativeInterstitialAdView.h>
#import <ADXLibrary/ADXNativeInterstitialAdViewController.h>
#import "GADMAdapterAppLovinUtils.h"

@interface ADXAppLovinNativeInterstitialAd () <MANativeAdDelegate, ADXNativeInterstitialAdViewControllerDelegate, MAAdRevenueDelegate>

@property (weak) ADXMediationData *adxMediationData;
@property (nonatomic, strong) MANativeAdLoader *nativeAdLoader;
@property (nonatomic, strong) MAAd *nativeAd;
@property (nonatomic, strong) MANativeAdView *nativeAdView;

@property (nonatomic, strong) ADXNativeInterstitialAdViewController *adViewController;

@property (nonatomic, assign) BOOL adLoaded;

@end

@implementation ADXAppLovinNativeInterstitialAd

@synthesize delegate;

@synthesize adNetworkInfo;

- (BOOL)isLoaded {
    return self.adLoaded && self.nativeAd && self.adViewController;
}

- (void)loadAdWithMediationData:(ADXMediationData *)mediation {
    ADXDebugLog(@"loadAdWithMediationData");
    self.adxMediationData = mediation;
    self.adLoaded = NO;
    
    if (mediation == nil || [GADMAdapterAppLovinUtils isChildUser]) {
        NSError *error = [NSError errorWithDomain:ADXAppLovinErrorDomain code:ADXAdErrorNoMediationData];
        ADXDebugLogError(@"%@", error.description);
        
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        
        return;
    }

    __weak typeof(self) weakSelf = self;
    [ADXAppLovinAdapter initializeSdkWithConfiguration:nil completionHandler:^(BOOL success, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        if (error) {
            ADXDebugLogError(@"%@", error.description);
            strongSelf.adLoaded = NO;
            
            if ([strongSelf.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
                [strongSelf.delegate didFailToLoadAdWithError:error];
            }
            return;
        }
        
        [strongSelf requestAdWithMediationData:mediation];
    }];
}


- (void)requestAdWithMediationData:(ADXMediationData *)mediation {
    NSString *adUnitId = [mediation.customEventParams objectForKey:@"adunit_id"];
    
    if (adUnitId == nil || adUnitId.length == 0) {
        adUnitId = [mediation.customEventParams objectForKey:@"zone_id"];
    }
    
    if (adUnitId == nil || adUnitId.length == 0) {
        NSError *error = [NSError errorWithDomain:ADXAppLovinErrorDomain code:ADXAdErrorServerData description:@"Ad Unit ID cannot be nil."];
        ADXDebugLogError(@"%@", error.description);
        self.adLoaded = NO;
        
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        
        return;
    }
    
    ALSdk *sdk = [ADXAppLovinAdapter appLovinSdk];
    
    if (!sdk.initialized) {
        NSError *error = [NSError errorWithDomain:ADXAppLovinErrorDomain code:ADXAdErrorSdkNotInitialize description:@"AppLovin initialization failed."];
        ADXDebugLogError(@"%@", error.description);
        self.adLoaded = NO;
        
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        
        return;
    }
    
    ADXLogDebug(@"requestAd - %@", adUnitId);
    
    ADXNativeInterstitialAdView *adView = [[ADXNativeInterstitialAdView alloc] init];
    adView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    if ([adView respondsToSelector:@selector(nativeTitleTextLabel)] && adView.nativeTitleTextLabel) {
        [adView.nativeTitleTextLabel setTag:10];
        adView.nativeTitleTextLabel.userInteractionEnabled = YES;
    }
    
    if ([adView respondsToSelector:@selector(nativeMainTextLabel)] && adView.nativeMainTextLabel) {
        [adView.nativeMainTextLabel setTag:11];
        adView.nativeMainTextLabel.userInteractionEnabled = YES;
    }
    
    if ([adView respondsToSelector:@selector(nativeCallToActionButton)] && adView.nativeCallToActionButton) {
        [adView.nativeCallToActionButton setTag:12];
    }
    
    if ([adView respondsToSelector:@selector(nativeIconImageView)] && adView.nativeIconImageView) {
        [adView.nativeIconImageView setTag:13];
        adView.nativeIconImageView.userInteractionEnabled = YES;
    }
    
    if ([adView respondsToSelector:@selector(nativeMainImageView)] && adView.nativeMainImageView) {
        [adView.nativeMainImageView setTag:14];
        adView.nativeMainImageView.userInteractionEnabled = YES;
    }
    
    if ([adView respondsToSelector:@selector(nativeSponsoredByCompanyTextLabel)] && adView.nativeSponsoredByCompanyTextLabel) {
        [adView.nativeSponsoredByCompanyTextLabel setTag:15];
        adView.nativeSponsoredByCompanyTextLabel.userInteractionEnabled = YES;
    }
    
    if ([adView respondsToSelector:@selector(nativePrivacyInformationIconImageView)] && adView.nativePrivacyInformationIconImageView) {
        [adView.nativePrivacyInformationIconImageView setTag:16];
        adView.nativePrivacyInformationIconImageView.userInteractionEnabled = YES;
    }
    
    MANativeAdViewBinder *binder = [[MANativeAdViewBinder alloc] initWithBuilderBlock:^(MANativeAdViewBinderBuilder *builder) {
        builder.titleLabelTag = 10;
        builder.bodyLabelTag = 11;
        builder.callToActionButtonTag = 12;
        builder.iconImageViewTag = 13;
        builder.mediaContentViewTag = 14;
        builder.advertiserLabelTag = 15;
        builder.optionsContentViewTag = 16;
    }];
    
    self.nativeAdLoader = [[MANativeAdLoader alloc] initWithAdUnitIdentifier:adUnitId sdk:sdk];
    self.nativeAdLoader.nativeAdDelegate = self;
    self.nativeAdLoader.revenueDelegate = self;
    
    self.nativeAdView = [[MANativeAdView alloc] init];
    self.nativeAdView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.nativeAdView addSubview:adView];
    [self.nativeAdView bindViewsWithAdViewBinder:binder];
    
    [self.nativeAdLoader setExtraParameterForKey:@"disable_auto_retries" value:@"true"];
    [self.nativeAdLoader loadAdIntoAdView:self.nativeAdView];
}

- (void)showAdFromRootViewController:(UIViewController *)rootViewController {
    if (self.isLoaded) {
        [rootViewController presentViewController:self.adViewController animated:YES completion:nil];
    }
}

- (void)dealloc {
    if (self.nativeAd) {
        [self.nativeAdLoader destroyAd:self.nativeAd];
    }
    
    if (self.nativeAdView) {
        [self.nativeAdView removeFromSuperview];
    }
    
    self.nativeAdLoader.nativeAdDelegate = nil;
    self.nativeAdLoader.revenueDelegate = nil;
    self.nativeAdLoader = nil;
    
    self.adViewController = nil;
}

#pragma mark - MANativeAdDelegate

- (void)didLoadNativeAd:(MANativeAdView *)nativeAdView forAd:(MAAd *)ad {
    ADXLogDebug(@"didLoadNativeAd");
    
    if (!self.adLoaded) {
        if (self.nativeAd) {
            [self.nativeAdLoader destroyAd:self.nativeAd];
        }
        
        self.adLoaded = YES;
        
        self.nativeAd = ad;
        self.nativeAdView = nativeAdView;
        
        self.adViewController = [[ADXNativeInterstitialAdViewController alloc] init];
        self.adViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        self.adViewController.delegate = self;
        self.adViewController.adContentView = self.nativeAdView;
        
        if ([self.delegate respondsToSelector:@selector(didLoadAd)]) {
            [self.delegate didLoadAd];
        }
    }
}

- (void)didFailToLoadNativeAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error {
    ADXLogError(@"didFailToLoadNativeAdForAdUnitIdentifier: %@ / Code=%ld %@", adUnitIdentifier, error.code, error.message);
    self.adLoaded = NO;
    if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
        [self.delegate didFailToLoadAdWithError:[NSError errorWithDomain:ADXAppLovinErrorDomain code:ADXAdErrorNoFill]];
    }
}

- (void)didClickNativeAd:(MAAd *)ad {
    ADXLogDebug(@"didClickNativeAd");
    
    if ([self.delegate respondsToSelector:@selector(didClickAd)]) {
        [self.delegate didClickAd];
    }
}


#pragma mark - ADXNativeInterstitialAdViewControllerDelegate

- (void)nativeInterstitialAdWillPresentScreen {
    ADXLogDebug(@"nativeInterstitialAdWillPresentScreen");
    
    if ([self.delegate respondsToSelector:@selector(willPresentScreen)]) {
        [self.delegate willPresentScreen];
    }
}

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

#pragma mark - MAAdRevenueDelegate Protocol

- (void)didPayRevenueForAd:(MAAd *)ad {
    ADXLogDebug(@"didPayRevenueForAd");
    [ADXAppLovinAdapter printAdNetworkResponseInfo:ad];
    
    // The value of ad.revenue may be -1 in the case of an error.
    // The ad’s revenue amount. In the case where no revenue amount exists, or it is not available yet, will return a value of 0.
    double revenue = ad.revenue >= 0 ? ad.revenue * 1000 : self.adxMediationData.ecpm; // In USD
    /**
     * The precision of the revenue value for this ad.
     *
     * Possible values are:
     * - "publisher_defined" - If the revenue is the price assigned to the line item by the publisher.
     * - "exact" - If the revenue is the resulting price of a real-time auction.
     * - "estimated" - If the revenue is the price obtained by auto-CPM.
     * - "undefined" - If we do not have permission from the ad network to share impression-level data.
     */
    NSString *revenuePrecision = ad.revenuePrecision;
    NSString *networkName = ad.networkName;
    ADXLogDebug(@"didPayRevenueForAd, %@ ecpm: %f, %@", networkName, revenue, revenuePrecision);
    if ([self.delegate respondsToSelector:@selector(didPaidEvent:)]) {
        [self.delegate didPaidEvent:revenue];
    }
}

@end
