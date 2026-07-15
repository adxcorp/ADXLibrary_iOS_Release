//
//  ADXAppLovinInterstitialAd.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "ADXAppLovinInterstitialAd.h"

#import "ADXAppLovinAdapter.h"

@interface ADXAppLovinInterstitialAd () <MAAdDelegate, MAAdRevenueDelegate>

@property (weak) ADXMediationData *adxMediationData;
@property (nonatomic, strong) MAInterstitialAd *interstitialAd;
@property (nonatomic, assign) BOOL adLoaded;

@end

@implementation ADXAppLovinInterstitialAd

@synthesize delegate;
@synthesize adNetworkInfo;

- (BOOL)isLoaded {
    return self.adLoaded && self.interstitialAd;
}

- (void)loadAdWithMediationData:(ADXMediationData *)mediation {
    ADXDebugLog(@"loadAdWithMediationData");
    self.adxMediationData = mediation;
    
    if (mediation == nil) {
        NSError *error = [NSError errorWithDomain:ADXAppLovinErrorDomain code:ADXAdErrorNoMediationData];
        ADXDebugLogError(@"%@", error.description);
        self.adLoaded = NO;
        
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
    if (mediation.enableBiddingKit) {
        adUnitId = mediation.biddingKitAdUnitId;
        ALSdkSettings *sdkSettings = [[ADXAppLovinAdapter appLovinSdk] settings];
        NSString *unitIds = [ADXAppLovinAdapter getAppLovinAdUnitIDs:adUnitId];
        [sdkSettings setExtraParameterForKey:@"disable_b2b_ad_unit_ids" value:unitIds];
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
    
    self.interstitialAd = [[MAInterstitialAd alloc] initWithAdUnitIdentifier:adUnitId sdk:sdk];
    [self.interstitialAd setExtraParameterForKey:@"disable_auto_retries" value:@"true"];
    self.interstitialAd.delegate = self;
    self.interstitialAd.revenueDelegate = self;
    
    if (mediation.enableBiddingKit) {
        NSString *ecpm = [NSString stringWithFormat:@"%g", mediation.ecpm];
        // bidding using applovin custom adapter
        ADXLogDebug(@"biddingPlatform - %@", [self.adxMediationData biddingPlatform]);
        if([[self.adxMediationData biddingPlatform] isEqualToString:@"max"]){
            NSMutableDictionary * dictionary = [@{
                @"format" : @(ADXADX_AD_FORMAT_INTERSTITIAL),
                @"ecpm" : ecpm,
                @"enable_bidding" : @1,
            } mutableCopy];
            if(self.loadedAd) { dictionary[@"custom_event"] = self.loadedAd; }
            // setLocalExtraParameterForKey
            [self.interstitialAd setLocalExtraParameterForKey:@"adx_local_data" value:dictionary];
        } else {
            // bidding kit
            [self.interstitialAd setExtraParameterForKey:ADXAppLovinBiddingKitKey value:ecpm];
        }
        ADXLogDebug(@"[Bidding] requestAd - %@", adUnitId);
        
    } else {
        ADXLogDebug(@"requestAd - %@", adUnitId);
    }
    
    [self.interstitialAd loadAd];
}

- (void)showAdFromRootViewController:(UIViewController *)rootViewController {
    if (self.isLoaded && self.interstitialAd.isReady) {
        ADXLogDebug(@"showAd - %@", self.interstitialAd.adUnitIdentifier);
        
        [self.interstitialAd showAd];
        self.adLoaded = NO;
        
    } else {
        ADXLogDebug(@"Interstitial ad is not ready to be presented.");
    }
}

- (void)dealloc {
    [self releaseInterstitialAd];
    self.delegate = nil;
}

- (void)releaseInterstitialAd {
    if (self.interstitialAd != nil) {
        [self.interstitialAd setLocalExtraParameterForKey:@"adx_local_data" value:@{}];
        self.interstitialAd.delegate = nil;
        self.interstitialAd.revenueDelegate = nil;
        self.interstitialAd = nil;
    }
}

#pragma mark - MAAdDelegate

- (void)didLoadAd:(MAAd *)ad {
    ADXLogDebug(@"didLoadAd");
    [ADXAppLovinAdapter printAdNetworkResponseInfo:ad];
    if (!self.adLoaded) {
        self.adLoaded = YES;
        self.adNetworkInfo = [ADXAppLovinAdapter adNetworkInfoFromAd:ad];
        if ([self.delegate respondsToSelector:@selector(didLoadAd)]) {
            [self.delegate didLoadAd];
        }
    }
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error {
    ADXLogError(@"didFailToLoadAdForAdUnitIdentifier: %@ / Code=%ld %@", adUnitIdentifier, error.code, error.message);
    self.adLoaded = NO;
    [self releaseInterstitialAd];
    if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
        [self.delegate didFailToLoadAdWithError:[NSError errorWithDomain:ADXAppLovinErrorDomain code:ADXAdErrorNoFill]];
    }
}

- (void)didDisplayAd:(MAAd *)ad {
    ADXLogDebug(@"didDisplayAd");
    [ADXAppLovinAdapter printAdNetworkResponseInfo:ad];
    if ([self.delegate respondsToSelector:@selector(willPresentScreen)]) {
        [self.delegate willPresentScreen];
    }
}

- (void)didFailToDisplayAd:(nonnull MAAd *)ad withError:(nonnull MAError *)error {
    ADXLogError(@"didFailToDisplayAd: %@ / Code=%ld %@", ad.adUnitIdentifier, error.code, error.message);
    self.adLoaded = NO;
    [self releaseInterstitialAd];
    if ([self.delegate respondsToSelector:@selector(didFailToShowAdWithError:)]) {
        [self.delegate didFailToShowAdWithError:[NSError errorWithDomain:ADXAppLovinErrorDomain code:ADXAdErrorNoFill]];
    }
}

- (void)didClickAd:(MAAd *)ad {
    ADXLogDebug(@"didClickAd");
    
    if ([self.delegate respondsToSelector:@selector(didClickAd)]) {
        [self.delegate didClickAd];
    }
}

- (void)didHideAd:(MAAd *)ad {
    ADXLogDebug(@"didHideAd");
    self.adLoaded = NO;
    
    if ([self.delegate respondsToSelector:@selector(willDismissScreen)]) {
        [self.delegate willDismissScreen];
    }
    
    if ([self.delegate respondsToSelector:@selector(didDismissScreen)]) {
        [self.delegate didDismissScreen];
    }
    
    [self releaseInterstitialAd];
}

#pragma mark - MAAdRevenueDelegate Protocol

- (void)didPayRevenueForAd:(MAAd *)ad {
    ADXLogDebug(@"didPayRevenueForAd");
    
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
