//
//  ADXAppLovinBannerAd.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "ADXAppLovinBannerAd.h"

#import "ADXAppLovinAdapter.h"

@interface ADXAppLovinBannerAd () <MAAdViewAdDelegate, MAAdRevenueDelegate>

@property (nonatomic, strong) MAAdView *adView;
@property (nonatomic, assign) BOOL adLoaded;
@property (weak) ADXMediationData *adxMediationData;

@end

@implementation ADXAppLovinBannerAd

@synthesize delegate;
@synthesize adNetworkInfo;

- (BOOL)isLoaded {
    return self.adLoaded && self.adView;
}

- (void)loadAdWithMediationData:(ADXMediationData *)mediation adSize:(ADXAdSize)adSize rootViewControoler:(UIViewController *)rootViewController {
    ADXDebugLog(@"loadAdWithMediationData");

    if (mediation == nil) {
        NSError *error = [NSError errorWithDomain:ADXAppLovinErrorDomain code:ADXAdErrorNoMediationData];
        ADXDebugLogError(@"%@", error.description);
        self.adLoaded = NO;
        
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        
        return;
    }
    
    self.adxMediationData = mediation;
    
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
        
        [strongSelf requestAdWithMediationData:mediation adSize:adSize];
    }];
}

- (void)requestAdWithMediationData:(ADXMediationData *)mediation adSize:(ADXAdSize)adSize {
    NSString *adUnitId = [mediation.customEventParams objectForKey:@"adunit_id"];
    
    if (mediation.enableBiddingKit) {
        adUnitId = mediation.biddingKitAdUnitId;
    } else if (adUnitId == nil || adUnitId.length == 0) {
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
    
    if (mediation.enableBiddingKit) {
        self.adView = [[MAAdView alloc] initWithAdUnitIdentifier:adUnitId sdk:sdk];
        // disable sequential caching
        [self.adView setExtraParameterForKey:@"disable_precache" value:@"true"];
    } else {
        self.adView = [[MAAdView alloc] initWithAdUnitIdentifier:adUnitId sdk:sdk];
    }
    
    self.adView.delegate = self;
    self.adView.revenueDelegate = self;
    
    [self.adView setExtraParameterForKey:@"disable_auto_retries" value:@"true"];
    [self.adView setExtraParameterForKey:@"allow_pause_auto_refresh_immediately" value:@"true"];
    [self.adView stopAutoRefresh];
    self.adView.frame = CGRectMake(0, 0, adSize.width, adSize.height);
    
    if (mediation.enableBiddingKit) {
        NSString *ecpm = [NSString stringWithFormat:@"%g", mediation.ecpm];
        // bidding using applovin custom adapter
        ADXLogDebug(@"biddingPlatform - %@", [mediation biddingPlatform]);
        if([[mediation biddingPlatform] isEqualToString:@"max"]){
            NSMutableDictionary * dictionary = [@{
                @"format" : @(ADX_AD_FORMAT_BANNER),
                @"ecpm" : ecpm,
                @"enable_bidding" : @1,
            } mutableCopy];
            if(self.loadedAd) { dictionary[@"custom_event"] = self.loadedAd; }
            if(self.bannerView) { dictionary[@"custom_banner_view"] = self.bannerView; }
            // setLocalExtraParameterForKey
            [self.adView setLocalExtraParameterForKey:@"adx_local_data" value:dictionary];
        } else {
            // bidding kit
            [self.adView setExtraParameterForKey:ADXAppLovinBiddingKitKey value:ecpm];
        }
        ADXLogDebug(@"[Bidding] requestAd - %@", adUnitId);
        
    } else {
        ADXLogDebug(@"requestAd - %@", adUnitId);
    }
    
    [self.adView loadAd];
}

- (void)dealloc {
    [self releaseBannerAd];
    self.delegate = nil;
}

- (void)releaseBannerAd {
    if (self.adView != nil) {
        [self.adView setLocalExtraParameterForKey:@"adx_local_data" value:@{}];
        self.adView.delegate = nil;
        self.adView = nil;
    }
}


#pragma mark - MAAdViewAdDelegate

- (void)didLoadAd:(nonnull MAAd *)ad {
    ADXLogDebug(@"didLoadAd");
    [ADXAppLovinAdapter printAdNetworkResponseInfo:ad];
    
    self.adLoaded = YES;
    self.adNetworkInfo = [ADXAppLovinAdapter adNetworkInfoFromAd:ad];
    
    if (self.adView && [self.delegate respondsToSelector:@selector(didLoadAdView:)]) {
        [self.adView stopAutoRefresh];
        [self.delegate didLoadAdView:self.adView];
    }
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error {
    ADXLogError(@"didFailToLoadAdForAdUnitIdentifier: %@ / Code=%ld %@", adUnitIdentifier, error.code, error.message);
    self.adLoaded = NO;
    [self releaseBannerAd];
    if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
        [self.delegate didFailToLoadAdWithError:[NSError errorWithDomain:ADXAppLovinErrorDomain code:ADXAdErrorNoFill]];
    }
}

- (void)didClickAd:(nonnull MAAd *)ad {
    ADXLogDebug(@"didClickAd");
    
    if ([self.delegate respondsToSelector:@selector(didClickAd)]) {
        [self.delegate didClickAd];
    }
}

- (void)didFailToDisplayAd:(nonnull MAAd *)ad withError:(nonnull MAError *)error {}
- (void)didExpandAd:(nonnull MAAd *)ad {}
- (void)didCollapseAd:(nonnull MAAd *)ad {}


#pragma mark - Deprecated Callbacks

- (void)didDisplayAd:(nonnull MAAd *)ad {}
- (void)didHideAd:(nonnull MAAd *)ad {}

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
