//
//  ADXUnityAdsInterstitialAd.m
//  ADXLibrary-UnityAds
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "ADXUnityAdsInterstitialAd.h"

#import "ADXUnityAdsAdapter.h"
#import <ADXLibrary/ADXAdError.h>

@interface ADXUnityAdsInterstitialAd () <UnityAdsLoadDelegate, UnityAdsShowDelegate>

@property (nonatomic, copy) NSString *placementId;
@property (nonatomic, assign) BOOL adLoaded;

@end

@implementation ADXUnityAdsInterstitialAd

@synthesize delegate;
@synthesize adNetworkInfo;

- (BOOL)isLoaded {
    return self.adLoaded && self.placementId;
}

- (void)loadAdWithMediationData:(ADXMediationData *)mediation {
    ADXDebugLog(@"loadAdWithMediationData");
   
    if (mediation == nil || mediation.customEventParams == nil) {
        NSError *error = [NSError errorWithDomain:ADXUnityAdsErrorDomain code:ADXAdErrorNoMediationData];
        ADXDebugLogError(@"%@", error.description);
        self.adLoaded = NO;
        
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [ADXUnityAdsAdapter initializeSdkWithConfiguration:mediation.customEventParams completionHandler:^(BOOL success, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        if (error) {
            ADXDebugLogError(@"%@", error.description);
            strongSelf.adLoaded = NO;
            
            if ([strongSelf.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
                [strongSelf.delegate didFailToLoadAdWithError:error];
            }
            
            return;
        }
        
        NSString *placementId = [mediation.customEventParams objectForKey:@"placement_id"];
        [strongSelf requestAdWithPlacementId:placementId];
    }];
}

- (void)requestAdWithPlacementId:(NSString *)placementId {
    if (placementId == nil || placementId.length == 0) {
        NSError *error = [NSError errorWithDomain:ADXUnityAdsErrorDomain code:ADXAdErrorServerData description:@"Placement ID cannot be nil."];
        ADXDebugLogError(@"%@", error.description);
        self.adLoaded = NO;
        
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        return;
    }
    
    ADXLogDebug(@"requestAd Placement ID - %@", placementId);
    
    self.placementId = placementId;
    [UnityAds load:placementId loadDelegate:self];
}

- (void)showAdFromRootViewController:(UIViewController *)rootViewController {
    if (self.isLoaded && rootViewController != nil) {
        ADXDebugLog(@"showAdFromRootViewController");
        [UnityAds show:rootViewController placementId:self.placementId showDelegate:self];
        
    } else {
        ADXLogWarning(@"Unity Ads received call to show before successfully loading an ad");
    }
}

- (void)dealloc {
    ADXDebugLog(@"dealloc");
    self.delegate = nil;
}


#pragma mark - UnityAdsLoadDelegate

- (void)unityAdsAdLoaded: (NSString *)placementId {
    if (!self.adLoaded) {
        self.adLoaded = YES;
        
        ADXLogDebug(@"unityAdsAdLoaded: %@", placementId);
        
        if ([self.delegate respondsToSelector:@selector(didLoadAd)]) {
            [self.delegate didLoadAd];
        }
    }
}

- (void)unityAdsAdFailedToLoad:(NSString *)placementId
                     withError:(UnityAdsLoadError)error
                   withMessage:(NSString *)message {
    ADXLogError(@"unityAdsAdFailedToLoad: %@ / %@", placementId, message);
    self.adLoaded = NO;
    
    if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
        [self.delegate didFailToLoadAdWithError:[NSError errorWithDomain:ADXUnityAdsErrorDomain code:ADXAdErrorNoFill]];
    }
}

#pragma mark - UnityAdsShowDelegate

- (void)unityAdsShowComplete:(NSString *)placementId withFinishState:(UnityAdsShowCompletionState)state {
    ADXLogDebug(@"unityAdsShowComplete: %@", placementId);
    
    self.adLoaded = NO;
    
    if ([self.delegate respondsToSelector:@selector(willDismissScreen)]) {
        [self.delegate willDismissScreen];
    }
    
    if ([self.delegate respondsToSelector:@selector(didDismissScreen)]) {
        [self.delegate didDismissScreen];
    }
}

- (void)unityAdsShowFailed:(NSString *)placementId withError:(UnityAdsShowError)error withMessage:(NSString *)message {
    ADXLogError(@"unityAdsShowFailed: %@ / %@", placementId, message);
    self.adLoaded = NO;
    
    if ([self.delegate respondsToSelector:@selector(didFailToShowAdWithError:)]) {
        [self.delegate didFailToShowAdWithError:[NSError errorWithDomain:ADXUnityAdsErrorDomain code:ADXAdErrorNoFill]];
    }
}

- (void)unityAdsShowStart:(NSString *)placementId {
    ADXLogDebug(@"unityAdsShowStart - %@", placementId);
    
    if ([self.delegate respondsToSelector:@selector(willPresentScreen)]) {
        [self.delegate willPresentScreen];
    }
}

- (void)unityAdsShowClick:(NSString *)placementId {
    ADXLogDebug(@"unityAdsShowClick - %@", placementId);
    
    if ([self.delegate respondsToSelector:@selector(didClickAd)]) {
        [self.delegate didClickAd];
    }
}

@end
