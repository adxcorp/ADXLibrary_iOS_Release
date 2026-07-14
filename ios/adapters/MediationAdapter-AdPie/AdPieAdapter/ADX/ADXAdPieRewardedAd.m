//
//  ADXAdPieRewardedAd.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "ADXAdPieRewardedAd.h"

#import "ADXAdPieAdapter.h"

#import "AdPieRewardedAdViewController.h"
#import "AdPieResponse.h"

#import <ADXLibrary/ADXAdError.h>
#import <ADXLibrary/ADXLog.h>

@interface ADXAdPieRewardedAd () <APRewardedAdDelegate, AdPieRewardedAdViewControllerDelegate>

@property (strong) APRewardedAd *rewardedAd;
@property (strong) AdPieRewardedAdViewController *rewardedAdViewController;
@property (assign) BOOL isBidResponse;
@property (assign) BOOL adLoaded;
@property (weak) ADXMediationData *adxMediationData;

@end

@implementation ADXAdPieRewardedAd

@synthesize delegate;
@synthesize adNetworkInfo;

- (BOOL)isLoaded {
    return self.adLoaded;
}

- (double)getPrice {
    // AdPie SDK 1.6.14 이하 버전 미지원 (1.6.15 이상 버전에서 지원)
    APRewardedAd * rewardedAd = self.rewardedAd;
    if (!rewardedAd) { return 0; }
    // selector 존재 여부 확인
    SEL selector = @selector(getPrice);
    if (![rewardedAd respondsToSelector:selector]) { return 0; }
    // IMP 안전 캐스팅
    typedef double (*PriceMethod)(id, SEL);
    PriceMethod method = (PriceMethod)[rewardedAd methodForSelector:selector];
    double eCPM = method ? method(rewardedAd, selector) : 0;
    ADXLogDebug(@"eCPM: %f", eCPM);
    return eCPM;
}


- (void)loadAdWithMediationData:(ADXMediationData *)mediation {
    ADXDebugLog(@"loadAdWithMediationData");
    self.adxMediationData = mediation;
    
    if (mediation == nil) {
        NSError *error = [NSError errorWithDomain:ADXAdPieErrorDomain code:ADXAdErrorNoMediationData];
        ADXDebugLogError(@"%@", error.description);
        self.adLoaded = NO;
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        return;
    }
    
    if (mediation.bidResponse == nil && mediation.customEventParams == nil) {
        NSError *error = [NSError errorWithCode:ADXAdErrorNoMediationData];
        ADXDebugLogError(@"%@", error.description);
        self.adLoaded = NO;
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        return;
    }
    
    // bidding
    if (mediation.bidResponse != nil) {
        AdPieResponse *bidResponse = [[AdPieResponse alloc] initWithDictionary:mediation.bidResponse];
        if (bidResponse.result != 0 || bidResponse.count != 1 || bidResponse.adData == nil || bidResponse.adData.icType != AdPieAdContentTypeRewardedVideo) {
            NSError *error = [NSError errorWithDomain:ADXAdPieErrorDomain code:ADXAdErrorServerData];
            ADXDebugLogError(@"%@", error.description);
            self.adLoaded = NO;
            if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
                [self.delegate didFailToLoadAdWithError:error];
            }
            return;
        }
        
        ADXLogDebug(@"requestAd");
        self.isBidResponse = YES;
        AdPieVideoAdData *adData = (AdPieVideoAdData *)bidResponse.adData;
        self.rewardedAdViewController = [[AdPieRewardedAdViewController alloc] init];
        self.rewardedAdViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        self.rewardedAdViewController.delegate = self;
        [self.rewardedAdViewController loadAdWithData:adData];
        return;
    }
    
    // waterfall
    __weak typeof(self) weakSelf = self;
    [ADXAdPieAdapter initializeSdkWithConfiguration:mediation.customEventParams completionHandler:^(BOOL success, NSError * _Nullable error) {
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
    NSString *slotId = [mediation.customEventParams objectForKey:@"sid"];
    
    if (slotId == nil || slotId.length == 0) {
        NSError *error = [NSError errorWithDomain:ADXAdPieErrorDomain code:ADXAdErrorServerData description:@"Slot ID cannot be nil."];
        ADXDebugLogError(@"%@", error.description);
        self.adLoaded = NO;
        
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        return;
    }
    
    ADXLogDebug(@"requestAd - %@", slotId);
    
    self.isBidResponse = NO;
    self.rewardedAd = [[APRewardedAd alloc] initWithSlotId:slotId];
    self.rewardedAd.delegate = self;
    
    __weak typeof(self) weakSelf = self;
    self.rewardedAd.onPaidEvent = ^(double eCPM) {
        __strong typeof(self) strongSelf = weakSelf;
        if(!strongSelf) { return; }
        if (![strongSelf.delegate respondsToSelector:@selector(didPaidEvent:)]) {
            ADXLogDebug(@"AdPie,selector(didPaidEvent:) does not exist.");
            return;
        }
        ADXLogDebug(@"AdPie,onPaidEvent, eCPM: %f", eCPM);
        [strongSelf.delegate didPaidEvent:eCPM];
    };
    
    [self.rewardedAd setExtraParameterForKey:@"floorPrice" value:[NSString stringWithFormat:@"%g", mediation.ecpm]];
    [self.rewardedAd load];
}

- (void)showAdFromRootViewController:(UIViewController *)rootViewController {
    if (!self.isLoaded || rootViewController == nil) {
        ADXLogDebug(@"Rewarded ad is not ready to be presented.");
        return;
    }
    
    if (self.rewardedAd && !self.isBidResponse) {
        ADXLogDebug(@"showAd - %@", self.rewardedAd.slotId);
        
        [self.rewardedAd presentFromRootViewController:rootViewController];
        
    } else if (self.rewardedAdViewController && self.isBidResponse) {
        ADXDebugLog(@"showAd");
        
        [self.rewardedAdViewController show];
        [rootViewController presentViewController:self.rewardedAdViewController animated:YES completion:nil];
        
    } else {
        ADXLogDebug(@"Rewarded ad is not ready to be presented.");
    }
}

- (void)dealloc {
    ADXDebugLog(@"dealloc");
    if (self.rewardedAd) {
        self.rewardedAd.delegate = nil;
        self.rewardedAd = nil;
    }
    
    if (self.rewardedAdViewController) {
        self.rewardedAdViewController.delegate = nil;
        self.rewardedAdViewController = nil;
    }
    
    self.delegate = nil;
}


#pragma mark - APRewardedAdDelegate

- (void)rewardedAdDidLoadAd:(APRewardedAd *)rewardedAd {
    ADXLogDebug(@"rewardedAdDidLoadAd");
    
    if (!self.adLoaded) {
        self.adLoaded = YES;
        double eCPM = [self getPrice];
        double revenue = eCPM > 0 ? eCPM / 1000 : 0.0;
        self.adNetworkInfo = @{ @"revenue" : @(revenue) };
        if ([self.delegate respondsToSelector:@selector(didLoadAd)]) {
            [self.delegate didLoadAd];
        }
    }
}

- (void)rewardedAdDidFailToLoadAd:(APRewardedAd *)rewardedAd withError:(NSError *)error {
    ADXLogError(@"rewardedAdDidFailToLoadAd:withError: %@", error);
    self.adLoaded = NO;
    
    if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
        [self.delegate didFailToLoadAdWithError:[NSError errorWithDomain:ADXAdPieErrorDomain code:ADXAdErrorNoFill]];
    }
}

- (void)rewardedAdWillPresentScreen:(APRewardedAd *)rewardedAd {
    ADXLogDebug(@"rewardedAdWillPresentScreen");
    
    if ([self.delegate respondsToSelector:@selector(willPresentScreen)]) {
        [self.delegate willPresentScreen];
    }
}

- (void)rewardedAdWillDismissScreen:(APRewardedAd *)rewardedAd {
    ADXLogDebug(@"rewardedAdWillDismissScreen");
    
    if ([self.delegate respondsToSelector:@selector(willDismissScreen)]) {
        [self.delegate willDismissScreen];
    }
}

- (void)rewardedAdDidDismissScreen:(APRewardedAd *)rewardedAd {
    ADXLogDebug(@"rewardedAdDidDismissScreen");
    self.adLoaded = NO;
    
    if ([self.delegate respondsToSelector:@selector(didDismissScreen)]) {
        [self.delegate didDismissScreen];
    }
}

- (void)rewardedAdWillLeaveApplication:(APRewardedAd *)rewardedAd {
    ADXLogDebug(@"rewardedAdWillLeaveApplication");
    
    if ([self.delegate respondsToSelector:@selector(didClickAd)]) {
        [self.delegate didClickAd];
    }
}

- (void)rewardedAdDidEarnReward:(APRewardedAd *)rewardedAd {
    ADXLogDebug(@"rewardedAdDidEarnReward");
    
    if ([self.delegate respondsToSelector:@selector(didRewardUserWithReward:)]) {
        ADXReward *reward = [ADXReward unspecifiedReward];
        [self.delegate didRewardUserWithReward:reward];
    }
}


#pragma mark - AdPieRewardedAdViewControllerDelegate

- (void)rewardedAdDidLoad {
    ADXLogDebug(@"rewardedAdDidLoad");
    
    if (!self.adLoaded) {
        self.adLoaded = YES;
        
        if ([self.delegate respondsToSelector:@selector(didLoadAd)]) {
            [self.delegate didLoadAd];
        }
    }
}

- (void)rewardedAdDidFailToLoadWithError:(NSError *)error {
    ADXLogError(@"rewardedAdDidFailToLoadWithError: %@", error.description);
    self.adLoaded = NO;
    
    if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
        [self.delegate didFailToLoadAdWithError:[NSError errorWithDomain:ADXAdPieErrorDomain code:ADXAdErrorNoFill]];
    }
}

- (void)rewardedAdWillPresentScreen {
    ADXLogDebug(@"rewardedAdWillPresentScreen");
    
    if ([self.delegate respondsToSelector:@selector(willPresentScreen)]) {
        [self.delegate willPresentScreen];
    }
}

- (void)rewardedAdWillDismissScreen {
    ADXLogDebug(@"rewardedAdWillDismissScreen");
    
    if ([self.delegate respondsToSelector:@selector(willDismissScreen)]) {
        [self.delegate willDismissScreen];
    }
}

- (void)rewardedAdDidDismissScreen {
    ADXLogDebug(@"rewardedAdDidDismissScreen");
    self.adLoaded = NO;
    
    if ([self.delegate respondsToSelector:@selector(didDismissScreen)]) {
        [self.delegate didDismissScreen];
    }
}

- (void)rewardedAdDidClick {
    ADXLogDebug(@"rewardedAdDidClick");
    
    if ([self.delegate respondsToSelector:@selector(didClickAd)]) {
        [self.delegate didClickAd];
    }
}

- (void)rewardedAdDidEarnReward {
    ADXLogDebug(@"rewardedAdDidEarnReward");
    
    if ([self.delegate respondsToSelector:@selector(didRewardUserWithReward:)]) {
        ADXReward *reward = [ADXReward unspecifiedReward];
        [self.delegate didRewardUserWithReward:reward];
    }
}

@end
