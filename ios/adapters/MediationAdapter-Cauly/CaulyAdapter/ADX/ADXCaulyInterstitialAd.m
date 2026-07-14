//
//  ADXCaulyInterstitialAd.m
//  ADXLibrary-Cauly
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "ADXCaulyInterstitialAd.h"

#import "ADXCaulyAdapter.h"

@interface ADXCaulyInterstitialAd () <CaulyInterstitialAdDelegate>
@property (strong) CaulyInterstitialAd * interstitialAd;
@property (assign) BOOL adLoaded;
@end

@implementation ADXCaulyInterstitialAd

@synthesize delegate;
@synthesize adNetworkInfo;

- (BOOL)isLoaded {
    return self.adLoaded && self.interstitialAd;
}

- (void)loadAdWithMediationData:(ADXMediationData *)mediation {
    ADXDebugLog(@"loadAdWithMediationData");
    if (mediation == nil || mediation.customEventParams == nil) {
        NSError *error = [NSError errorWithDomain:ADXCaulyErrorDomain code:ADXAdErrorNoMediationData];
        ADXDebugLogError(@"%@", error.description);
        self.adLoaded = NO;
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [ADXCaulyAdapter initializeSdkWithConfiguration:mediation.customEventParams 
                                  completionHandler:^(BOOL success, NSError * _Nullable error)
     {
        __strong typeof(self) strongSelf = weakSelf;
        if(!strongSelf) { return; }
        if (error) {
            ADXDebugLogError(@"%@", error.description);
            strongSelf.adLoaded = NO;
            if ([strongSelf.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
                [strongSelf.delegate didFailToLoadAdWithError:error];
            }
            return;
        }
        CaulyInterstitialAd * interstitialAd = [CaulyInterstitialAd new];
        interstitialAd.delegate = strongSelf;
        [interstitialAd startInterstitialAdRequest];
    }];
}

- (void)showAdFromRootViewController:(UIViewController *)rootViewController {
    if (![self isLoaded]) {
        ADXLogDebug(@"Interstitial ad is not ready to be presented.");
        return;
    }
    ADXDebugLog(@"showAdFromRootViewController");
    [self.interstitialAd showWithParentViewController:rootViewController];
}

- (void)dealloc {
    ADXDebugLog(@"dealloc");
    [self destroy];
}

- (void)destroy {
    self.delegate = nil;
    if(self.interstitialAd) {
        [self.interstitialAd setDelegate:nil];
        self.interstitialAd = nil;
    }
}


#pragma mark - CaulyInterstitialAdDelegate

- (void)didReceiveInterstitialAd:(CaulyInterstitialAd *)interstitialAd 
                  isChargeableAd:(BOOL)isChargeableAd
{
    ADXLogDebug(@"didReceiveInterstitialAd");
    if (self.adLoaded) { return; }
    self.interstitialAd = interstitialAd;
    self.adLoaded = YES;
    if ([self.delegate respondsToSelector:@selector(didLoadAd)]) {
        [self.delegate didLoadAd];
    }
}

- (void)didFailToReceiveInterstitialAd:(CaulyInterstitialAd *)interstitialAd 
                             errorCode:(int)errorCode
                              errorMsg:(NSString *)errorMsg
{
    ADXLogError(@"didFailToReceiveInterstitialAdError: %@", errorMsg);
    self.adLoaded = NO;
    self.interstitialAd = interstitialAd;
    if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
        [self.delegate didFailToLoadAdWithError:[NSError errorWithDomain:ADXCaulyErrorDomain code:ADXAdErrorNoFill]];
    }
    [self destroy];
}

- (void)willShowInterstitialAd:(CaulyInterstitialAd *)interstitialAd {
    ADXLogDebug(@"willShowInterstitialAd");
    if ([self.delegate respondsToSelector:@selector(willPresentScreen)]) {
        [self.delegate willPresentScreen];
    }
}

- (void)didCloseInterstitialAd:(CaulyInterstitialAd *)interstitialAd {
    ADXLogDebug(@"didCloseInterstitialAd");
    self.adLoaded = NO;
    
    if ([self.delegate respondsToSelector:@selector(willDismissScreen)]) {
        [self.delegate willDismissScreen];
    }
    
    if ([self.delegate respondsToSelector:@selector(didDismissScreen)]) {
        [self.delegate didDismissScreen];
    }
    
    [self destroy];
}

@end
