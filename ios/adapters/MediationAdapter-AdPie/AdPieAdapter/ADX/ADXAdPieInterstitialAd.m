//
//  ADXAdPieInterstitialAd.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "ADXAdPieInterstitialAd.h"

#import "ADXAdPieAdapter.h"

#import "AdPieInterstitialAdViewController.h"
#import "AdPieInterstitialVideoAdViewController.h"
#import "AdPieResponse.h"

#import <ADXLibrary/ADXAdError.h>
#import <ADXLibrary/ADXLog.h>

@interface ADXAdPieInterstitialAd () <APInterstitialDelegate, AdPieInterstitialAdViewControllerDelegate>

@property (strong) APInterstitial *interstitialAd;
@property (strong) AdPieInterstitialAdViewController *imageAdViewController;
@property (strong) AdPieInterstitialVideoAdViewController *videoAdViewController;
@property (assign) BOOL isBidResponse;
@property (assign) BOOL adLoaded;
@property (weak) ADXMediationData *adxMediationData;

@end

@implementation ADXAdPieInterstitialAd

@synthesize delegate;
@synthesize adNetworkInfo;

- (BOOL)isLoaded {
    return self.adLoaded;
}

- (double)getPrice {
    // AdPie SDK 1.6.14 이하 버전 미지원 (1.6.15 이상 버전에서 지원)
    APInterstitial * interstitialAd = self.interstitialAd;
    if (!interstitialAd) { return 0; }
    // selector 존재 여부 확인
    SEL selector = @selector(getPrice);
    if (![interstitialAd respondsToSelector:selector]) { return 0; }
    // IMP 안전 캐스팅
    typedef double (*PriceMethod)(id, SEL);
    PriceMethod method = (PriceMethod)[interstitialAd methodForSelector:selector];
    double eCPM = method ? method(interstitialAd, selector) : 0;
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
        NSError *error = [NSError errorWithDomain:ADXAdPieErrorDomain code:ADXAdErrorNoMediationData];
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
        
        BOOL errorServerData = NO;
        if (bidResponse.result != 0 || bidResponse.count != 1 || bidResponse.adData == nil) {
            errorServerData = YES;
        }
        
        if(bidResponse.adData.icType != AdPieAdContentTypeInterstitalImage &&
           bidResponse.adData.icType != AdPieAdContentTypeInterstitialIVideo)
        {
            errorServerData = YES;
        }
        
        if(errorServerData){
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
        if(bidResponse.adData.icType == AdPieAdContentTypeInterstitalImage){
            self.imageAdViewController = [[AdPieInterstitialAdViewController alloc] init];
            self.imageAdViewController.modalPresentationStyle = UIModalPresentationFullScreen;
            self.imageAdViewController.delegate = self;
            [self.imageAdViewController loadAdWithData:bidResponse.adData];
            if (self.videoAdViewController) {
                self.videoAdViewController.adDelegate = nil;
                self.videoAdViewController = nil;
            }
        }else{
            self.videoAdViewController = [[AdPieInterstitialVideoAdViewController alloc] init];
            self.videoAdViewController.modalPresentationStyle = UIModalPresentationFullScreen;
            self.videoAdViewController.adDelegate = self;
            [self.videoAdViewController loadAdWithData:(AdPieVideoAdData *)bidResponse.adData];
            if (self.imageAdViewController) {
                self.imageAdViewController.delegate = nil;
                self.imageAdViewController = nil;
            }
        }
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
    self.interstitialAd = [[APInterstitial alloc] initWithSlotId:slotId];
    self.interstitialAd.delegate = self;
    
    __weak typeof(self) weakSelf = self;
    self.interstitialAd.onPaidEvent = ^(double eCPM) {
        __strong typeof(self) strongSelf = weakSelf;
        if(!strongSelf) { return; }
        if (![strongSelf.delegate respondsToSelector:@selector(didPaidEvent:)]) {
            ADXLogDebug(@"AdPie,selector(didPaidEvent:) does not exist.");
            return;
        }
        ADXLogDebug(@"AdPie,onPaidEvent, eCPM: %f", eCPM);
        [strongSelf.delegate didPaidEvent:eCPM];
    };
    
    [self.interstitialAd setExtraParameterForKey:@"floorPrice" value:[NSString stringWithFormat:@"%g", mediation.ecpm]];
    [self.interstitialAd load];
}

- (void)showAdFromRootViewController:(UIViewController *)rootViewController {
    if (!self.isLoaded || rootViewController == nil) {
        ADXLogDebug(@"Interstitial ad is not ready to be presented.");
        
        return;
    }
    
    if (self.interstitialAd && !self.isBidResponse) {
        ADXLogDebug(@"ShowAd - %@", self.interstitialAd.slotId);
        [self.interstitialAd presentFromRootViewController:rootViewController];
    }else if (self.imageAdViewController && self.isBidResponse) {
        ADXDebugLog(@"showAd");
        if ([self.imageAdViewController.delegate respondsToSelector:@selector(interstitialAdWillPresentScreen)]) {
            [self.imageAdViewController.delegate interstitialAdWillPresentScreen];
        }
        [rootViewController presentViewController:self.imageAdViewController animated:YES completion:nil];
    }else if (self.videoAdViewController && self.isBidResponse) {
        ADXDebugLog(@"showAd");
        if ([self.videoAdViewController.adDelegate respondsToSelector:@selector(interstitialAdWillPresentScreen)]) {
            [self.videoAdViewController.adDelegate interstitialAdWillPresentScreen];
        }
        [rootViewController presentViewController:self.videoAdViewController animated:YES completion:nil];
    }else {
        ADXLogDebug(@"Interstitial ad is not ready to be presented.");
    }
}

- (void)dealloc {
    ADXDebugLog(@"dealloc");
    if (self.interstitialAd) {
        self.interstitialAd.delegate = nil;
        self.interstitialAd = nil;
    }
    
    if (self.imageAdViewController) {
        self.imageAdViewController.delegate = nil;
        self.imageAdViewController = nil;
    }
    
    if (self.videoAdViewController) {
        self.videoAdViewController.adDelegate = nil;
        self.videoAdViewController = nil;
    }
    
    self.delegate = nil;
}


#pragma mark - APInterstitialDelegate

- (void)interstitialDidLoadAd:(APInterstitial *)interstitial {
    ADXLogDebug(@"interstitialDidLoadAd");
    
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

- (void)interstitialDidFailToLoadAd:(APInterstitial *)interstitial withError:(NSError *)error {
    ADXLogError(@"interstitialDidFailToLoadAd: %@", error.description);
    self.adLoaded = NO;
    
    if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
        [self.delegate didFailToLoadAdWithError:[NSError errorWithDomain:ADXAdPieErrorDomain code:ADXAdErrorNoFill]];
    }
}

- (void)interstitialWillPresentScreen:(APInterstitial *)interstitial {
    ADXLogDebug(@"interstitialWillPresentScreen");
    
    if ([self.delegate respondsToSelector:@selector(willPresentScreen)]) {
        [self.delegate willPresentScreen];
    }
}

- (void)interstitialWillDismissScreen:(APInterstitial *)interstitial {
    ADXLogDebug(@"interstitialWillDismissScreen");
    
    if ([self.delegate respondsToSelector:@selector(willDismissScreen)]) {
        [self.delegate willDismissScreen];
    }
}

- (void)interstitialDidDismissScreen:(APInterstitial *)interstitial {
    ADXLogDebug(@"interstitialDidDismissScreen");
    self.adLoaded = NO;
    
    if ([self.delegate respondsToSelector:@selector(didDismissScreen)]) {
        [self.delegate didDismissScreen];
    }
}

- (void)interstitialWillLeaveApplication:(APInterstitial *)interstitial {
    ADXLogDebug(@"interstitialWillLeaveApplication");
    
    if ([self.delegate respondsToSelector:@selector(didClickAd)]) {
        [self.delegate didClickAd];
    }
}


#pragma mark - AdPieInterstitialAdViewControllerDelegate

- (void)interstitialAdDidLoad {
    ADXLogDebug(@"interstitialAdDidLoad");
    
    if (!self.adLoaded) {
        self.adLoaded = YES;
        
        if ([self.delegate respondsToSelector:@selector(didLoadAd)]) {
            [self.delegate didLoadAd];
        }
    }
}

- (void)interstitialAdDidFailToLoadWithError:(NSError *)error {
    ADXLogError(@"interstitialAdDidFailToLoadWithError: %@", error.description);
    self.adLoaded = NO;
    if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
        [self.delegate didFailToLoadAdWithError:error];
    }
}

- (void)interstitialAdDidFailToShowWithError:(NSError *)error {
    ADXLogError(@"interstitialAdDidFailToShowWithError: %@", error.description);
    self.adLoaded = NO;
    
    if ([self.delegate respondsToSelector:@selector(didFailToShowAdWithError:)]) {
        [self.delegate didFailToShowAdWithError:[NSError errorWithDomain:ADXAdPieErrorDomain code:ADXAdErrorNoFill]];
    }
}

- (void)interstitialAdWillPresentScreen {
    ADXLogDebug(@"interstitialAdWillPresentScreen");
    
    if ([self.delegate respondsToSelector:@selector(willPresentScreen)]) {
        [self.delegate willPresentScreen];
    }
}

- (void)interstitialAdWillDismissScreen {
    ADXLogDebug(@"interstitialAdWillDismissScreen");
    
    if ([self.delegate respondsToSelector:@selector(willDismissScreen)]) {
        [self.delegate willDismissScreen];
    }
}

- (void)interstitialAdDidDismissScreen {
    ADXLogDebug(@"interstitialAdDidDismissScreen");
    self.adLoaded = NO;
    
    if ([self.delegate respondsToSelector:@selector(didDismissScreen)]) {
        [self.delegate didDismissScreen];
    }
}

- (void)interstitialAdDidClick {
    ADXLogDebug(@"interstitialAdDidClick");
    
    if ([self.delegate respondsToSelector:@selector(didClickAd)]) {
        [self.delegate didClickAd];
    }
}

@end
