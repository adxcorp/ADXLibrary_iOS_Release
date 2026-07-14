//
//  ADXAdManagerInterstitialAd.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "ADXAdManagerInterstitialAd.h"

#import "ADXAdMobAdapter.h"

@interface ADXAdManagerInterstitialAd () <GADFullScreenContentDelegate>

@property (weak) ADXMediationData *adxMediationData;
@property (nonatomic, strong) GAMInterstitialAd *interstitialAd;
@property (nonatomic, assign) BOOL adLoaded;

@end

@implementation ADXAdManagerInterstitialAd

@synthesize delegate;
@synthesize adNetworkInfo;

- (BOOL)isLoaded {
    return self.adLoaded && self.interstitialAd;
}

- (void)loadAdWithMediationData:(ADXMediationData *)mediation {
    ADXDebugLog(@"loadAdWithMediationData");
    
    if (mediation == nil || mediation.customEventParams == nil) {
        NSError *error = [NSError errorWithDomain:ADXAdManagerErrorDomain code:ADXAdErrorNoMediationData];
        ADXDebugLogError(@"%@", error.description);
        self.adLoaded = NO;
        
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
        NSError *error = [NSError errorWithDomain:ADXAdManagerErrorDomain code:ADXAdErrorServerData description:@"Ad Unit ID cannot be nil."];
        ADXDebugLogError(@"%@", error.description);
        self.adLoaded = NO;
        
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        
        return;
    }
    
    ADXLogDebug(@"requestAd Ad Unit ID - %@", adUnitId);
    __weak typeof(self) weakSelf = self;
    [GAMInterstitialAd loadWithAdManagerAdUnitID:adUnitId
                                         request:[ADXAdMobAdapter gdprGAMRequest]
                               completionHandler:^(GAMInterstitialAd *interstitialAd, NSError *error) {
        __typeof__(self) strongSelf = weakSelf;
        if (error) {
            ADXLogError(@"fail to Load ad: %@", error.description);
            strongSelf.adLoaded = NO;
            
            if ([strongSelf.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
                [strongSelf.delegate didFailToLoadAdWithError:error];
            }
            
            return;
        }
        
        if (!strongSelf.adLoaded) {
            interstitialAd.paidEventHandler = ^(GADAdValue * _Nonnull value) {
                __typeof__(self) strongSelf = weakSelf;
                if(!strongSelf) {
                    ADXDebugLog(@"admanager, paidEventHandler, strongSelf is nil");
                    return;
                }
                if(![strongSelf adxMediationData]) {
                    ADXDebugLog(@"admanager, paidEventHandler, MediationData is nil");
                    return;
                }
                // Extract the impression-level ad revenue data.
                ADXDebugLog(@"admanager, paidEventHandler, ecpm: %f (%d)", [value.value doubleValue] * 1000, value.precision);
                double revenue = [value.value doubleValue] >= 0 ? [value.value doubleValue] * 1000 : strongSelf.adxMediationData.ecpm;
                if ([strongSelf.delegate respondsToSelector:@selector(didPaidEvent:)]) {
                    [strongSelf.delegate didPaidEvent:revenue];
                }
            };
            
            strongSelf.adLoaded = YES;
            strongSelf.interstitialAd = interstitialAd;
            strongSelf.interstitialAd.fullScreenContentDelegate = strongSelf;
            
            if ([strongSelf.delegate respondsToSelector:@selector(didLoadAd)]) {
                [strongSelf.delegate didLoadAd];
            }
        }
    }];
}

- (void)showAdFromRootViewController:(UIViewController *)rootViewController {
    if (self.isLoaded) {
        ADXDebugLog(@"showAdFromRootViewController");
        [self.interstitialAd presentFromRootViewController:rootViewController];
        
    } else {
        ADXLogDebug(@"Interstitial ad is not ready to be presented.");
    }
}

- (void)dealloc {
    ADXDebugLog(@"dealloc");
    if (self.interstitialAd != nil) {
        self.interstitialAd.fullScreenContentDelegate = nil;
        self.interstitialAd = nil;
    }
    
    self.delegate = nil;
}

#pragma mark - GADFullScreenContentDelegate

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
    ADXLogError(@"ad:didFailToPresentFullScreenContentWithError: %@", error.description);
    self.adLoaded = NO;
    
    if ([self.delegate respondsToSelector:@selector(didFailToShowAdWithError:)]) {
        [self.delegate didFailToShowAdWithError:[NSError errorWithDomain:ADXAdManagerErrorDomain code:ADXAdErrorNoFill]];
    }
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad {
    ADXLogDebug(@"adDidRecordClick");
    
    if ([self.delegate respondsToSelector:@selector(didClickAd)]) {
        [self.delegate didClickAd];
    }
}

- (void)adDidRecordImpression:(id<GADFullScreenPresentingAd>)ad {
    ADXLogDebug(@"adDidRecordImpression");
    
    if ([self.delegate respondsToSelector:@selector(willPresentScreen)]) {
        [self.delegate willPresentScreen];
    }
}

- (void)adWillDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
    ADXLogDebug(@"adWillDismissFullScreenContent");
    
    if ([self.delegate respondsToSelector:@selector(willDismissScreen)]) {
        [self.delegate willDismissScreen];
    }
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
    ADXLogDebug(@"adDidDismissFullScreenContent");
    self.adLoaded = NO;
    
    if ([self.delegate respondsToSelector:@selector(didDismissScreen)]) {
        [self.delegate didDismissScreen];
    }
}

@end
