//
//  ADXPangleInterstitialAd.m
//  ADXLibrary-Pangle
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <ADXLibrary/ADXAdError.h>
#import "ADXPangleInterstitialAd.h"
#import "ADXPangleAdapter.h"

@interface ADXPangleInterstitialAd () <PAGLInterstitialAdDelegate>
@property (assign) BOOL adLoaded;
@property PAGLInterstitialAd * interstitialAd;
@end

@implementation ADXPangleInterstitialAd

@synthesize delegate;
@synthesize adNetworkInfo;

- (BOOL)isLoaded {
    return self.adLoaded && self.interstitialAd != nil;
}

- (void)dealloc {
    ADXDebugLog(@"dealloc");
}

- (void)loadAdWithMediationData:(ADXMediationData *)mediation {
    ADXDebugLog(@"loadAdWithMediationData");
    __weak typeof(self) weakSelf = self;
    [ADXPangleAdapter initializeSdkWithConfiguration:mediation.customEventParams
                                   completionHandler:^(BOOL success, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (error || success == NO || strongSelf == nil) {
            ADXDebugLogError(@"%@", error.description);
            strongSelf.adLoaded = NO;
            if ([strongSelf.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
                ADXDebugLogError(@"%@", error.description);
                NSError * anError = [NSError errorWithDomain:ADXPangleErrorDomain
                                                        code:ADXAdErrorUnknown
                                                 description:[NSString stringWithFormat:@"%@",[error description]]];
                [strongSelf.delegate didFailToLoadAdWithError:anError];
            }
            return;
        }
        NSString * placementId = [mediation.customEventParams objectForKey:@"placement_id"];
        [strongSelf requestAdWithPlacementId:placementId];
    }];
}

- (void)requestAdWithPlacementId:(NSString *)placementId {
    ADXLogDebug(@"Placement ID - %@", placementId);
    if (![placementId length]) {
        NSError *error = [NSError errorWithDomain:ADXPangleErrorDomain
                                             code:ADXAdErrorInvalidRequest
                                      description:@"Placement ID cannot be nil."];
        ADXDebugLogError(@"%@", error.description);
        self.adLoaded = NO;
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    PAGInterstitialRequest * request = [PAGInterstitialRequest request];
    [PAGLInterstitialAd loadAdWithSlotID:placementId
                                 request:request
                       completionHandler:^(PAGLInterstitialAd * _Nullable interstitialAd, NSError * _Nullable error) {
        
        __strong typeof(self) strongSelf = weakSelf;
        if (error || interstitialAd == nil || strongSelf == nil) {
            ADXDebugLogError(@"load failed for interstitial Ad (%@)", error);
            strongSelf.adLoaded = NO;
            if ([strongSelf.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
                NSError * anError = [NSError errorWithDomain:ADXPangleErrorDomain
                                                        code:ADXAdErrorNoFill
                                                 description:[NSString stringWithFormat:@"%@", [error description]]];
                [strongSelf.delegate didFailToLoadAdWithError:anError];
            }
            return;
        }
        
        // Ad Loaded
        strongSelf.adLoaded = YES;
        strongSelf.interstitialAd = interstitialAd;
        strongSelf.interstitialAd.delegate = strongSelf;
        
        ADXLogDebug(@"didLoadAd");
        if ([strongSelf.delegate respondsToSelector:@selector(didLoadAd)]) {
            [strongSelf.delegate didLoadAd];
        }
    }];
}

- (void)showAdFromRootViewController:(UIViewController *)rootViewController {
    if (self.isLoaded == NO
        || self.interstitialAd == nil
        || rootViewController == nil)
    {
        ADXLogDebug(@"Interstitial ad is not ready to be presented.");
        if ([self.delegate respondsToSelector:@selector(didFailToShowAdWithError:)]) {
            NSError * error = [NSError errorWithDomain:ADXPangleErrorDomain code:ADXAdErrorUnknown];
            [self.delegate didFailToShowAdWithError:error];
        }
        return;
    }
    ADXLogDebug(@"presentFromRootViewController");
    [self.interstitialAd presentFromRootViewController:rootViewController];
}

- (void)prepareToLoadNewAd {
    self.adLoaded = NO;
    if(self.interstitialAd) {
        self.interstitialAd.delegate = nil;
        self.interstitialAd = nil;
    }
}

#pragma mark - PAGLInterstitialAdDelegate
/// This method is called when the ad has been shown
- (void)adDidShow:(id<PAGAdProtocol>)ad {
    ADXLogDebug(@"adDidShow");
    if ([self.delegate respondsToSelector:@selector(willPresentScreen)]) {
        [self.delegate willPresentScreen];
    }
}

/// This method is called when the add has been clicked
- (void)adDidClick:(id<PAGAdProtocol>)ad {
    ADXLogDebug(@"adDidClick");
    if ([self.delegate respondsToSelector:@selector(didClickAd)]) {
        [self.delegate didClickAd];
    }
}

///This method is called when the ad has been dismissed.
- (void)adDidDismiss:(id<PAGAdProtocol>)ad {
    ADXLogDebug(@"adDidDismiss");
    [self prepareToLoadNewAd];
    
    if ([self.delegate respondsToSelector:@selector(willDismissScreen)]) {
        [self.delegate willDismissScreen];
    }
    
    if ([self.delegate respondsToSelector:@selector(didDismissScreen)]) {
        [self.delegate didDismissScreen];
    }
}

///This method is called when the ad has been show fail
- (void)adDidShowFail:(id<PAGAdProtocol>)ad error:(NSError *)error {
    ADXLogDebug(@"adDidShowFail, %@", error);
    [self prepareToLoadNewAd];
    
    if ([self.delegate respondsToSelector:@selector(didFailToShowAdWithError:)]) {
        NSError *anError = [NSError errorWithDomain:ADXPangleErrorDomain
                                               code:ADXAdErrorUnknown
                                        description:[NSString stringWithFormat:@"%@",[error description]]];
        [self.delegate didFailToShowAdWithError:anError];
    }
}

@end
