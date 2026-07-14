//
//  ADXAdPieBannerAd.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "ADXAdPieBannerAd.h"

#import "ADXAdPieAdapter.h"

#import "AdPieAdView.h"
#import "AdPieResponse.h"

#import <ADXLibrary/ADXAdError.h>
#import <ADXLibrary/ADXLog.h>

@interface ADXAdPieBannerAd () <APAdViewDelegate, AdPieAdViewDelegate>

@property (strong) APAdView *adPieAdView;
@property (strong) AdPieAdView *adView;
@property (assign) BOOL isBidResponse;
@property (assign) BOOL adLoaded;
@property (weak, nullable) UIViewController *rootViewController;
@property (weak) ADXMediationData *adxMediationData;

@end

@implementation ADXAdPieBannerAd

@synthesize delegate;
@synthesize adNetworkInfo;

- (BOOL)isLoaded {
    return self.adLoaded;
}

- (double)getPrice {
    // AdPie SDK 1.6.14 이하 버전 미지원 (1.6.15 이상 버전에서 지원)
    APAdView * apAdView = self.adPieAdView;
    if (!apAdView) { return 0; }
    // selector 존재 여부 확인
    SEL selector = @selector(getPrice);
    if (![apAdView respondsToSelector:selector]) { return 0; }
    // IMP 안전 캐스팅
    typedef double (*PriceMethod)(id, SEL);
    PriceMethod method = (PriceMethod)[apAdView methodForSelector:selector];
    double eCPM = method ? method(apAdView, selector) : 0;
    ADXLogDebug(@"eCPM: %f", eCPM);
    return eCPM;
}

- (void)loadAdWithMediationData:(ADXMediationData *)mediation adSize:(ADXAdSize)adSize rootViewControoler:(UIViewController *)rootViewController {
    ADXDebugLog(@"loadAdWithMediationData");
    self.adxMediationData = mediation;
    
    if (mediation == nil) {
        NSError *error = [NSError errorWithCode:ADXAdErrorNoMediationData];
        ADXDebugLogError(@"%@", error.description);
        self.adLoaded = NO;
        
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        
        return;
    }
    
    self.rootViewController = rootViewController;
    
    if (mediation.bidResponse != nil) {
        // bidding
        AdPieResponse *bidResponse = [[AdPieResponse alloc] initWithDictionary:mediation.bidResponse];
        if (bidResponse.result != 0 || bidResponse.count != 1 || bidResponse.adData == nil || bidResponse.adData.icType != AdPieAdContentTypeBannerImage) {
            NSError *error = [NSError errorWithCode:ADXAdErrorServerData];
            ADXDebugLogError(@"%@", error.description);
            self.adLoaded = NO;
            
            if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
                [self.delegate didFailToLoadAdWithError:error];
            }
            
            return;
        }
        
        ADXLogDebug(@"requestAd");
        
        self.isBidResponse = YES;
        self.adView = [[AdPieAdView alloc] initWithFrame:CGRectMake(0, 0, adSize.width, adSize.height)];
        self.adView.rootViewController = self.rootViewController;
        self.adView.delegate = self;
        [self.adView loadAdWithData:bidResponse.adData];
        
    } else if (mediation.customEventParams != nil) {
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
            
            [strongSelf requestAdWithMediationData:mediation adSize:adSize];
            
        }];
        
    } else {
        NSError *error = [NSError errorWithDomain:ADXAdPieErrorDomain code:ADXAdErrorNoMediationData];
        ADXDebugLogError(@"%@", error.description);
        self.adLoaded = NO;
        
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
    }
}

- (void)requestAdWithMediationData:(ADXMediationData *)mediation adSize:(ADXAdSize)adSize{
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
    self.adPieAdView = [[APAdView alloc] initWithFrame:CGRectMake(0, 0, adSize.width, adSize.height)];
    self.adPieAdView.slotId = slotId;
    self.adPieAdView.rootViewController = self.rootViewController;
    self.adPieAdView.delegate = self;
    
    __weak typeof(self) weakSelf = self;
    self.adPieAdView.onPaidEvent = ^(double eCPM) {
        __strong typeof(self) strongSelf = weakSelf;
        if(!strongSelf) { return; }
        if (![strongSelf.delegate respondsToSelector:@selector(didPaidEvent:)]) {
            ADXLogDebug(@"AdPie,selector(didPaidEvent:) does not exist.");
            return;
        }
        ADXLogDebug(@"AdPie,onPaidEvent, eCPM: %f", eCPM);
        [strongSelf.delegate didPaidEvent:eCPM];
    };
    
    [self.adPieAdView setExtraParameterForKey:@"floorPrice" value:[NSString stringWithFormat:@"%g", mediation.ecpm]];
    [self.adPieAdView load];
}

- (void)dealloc {
    ADXDebugLog(@"dealloc");
    if (self.adPieAdView) {
        self.adPieAdView.delegate = nil;
        self.adPieAdView = nil;
    }
    
    if (self.adView) {
        self.adView.delegate = nil;
        self.adView = nil;
    }
    
    self.delegate = nil;
}


#pragma mark - APAdViewDelegate

- (void)adViewDidLoadAd:(APAdView *)view {
    ADXLogDebug(@"adViewDidLoadAd");
    self.adLoaded = YES;
    double eCPM = [self getPrice];
    double revenue = eCPM > 0 ? eCPM / 1000 : 0.0;
    self.adNetworkInfo = @{ @"revenue" : @(revenue) };
    if ([self.delegate respondsToSelector:@selector(didLoadAdView:)]) {
        [self.delegate didLoadAdView:view];
    }
}

- (void)adViewDidFailToLoadAd:(APAdView *)view withError:(NSError *)error {
    ADXLogError(@"adViewDidFailToLoadAd: %@", error.description);
    self.adLoaded = NO;
    if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
        [self.delegate didFailToLoadAdWithError:[NSError errorWithDomain:ADXAdPieErrorDomain code:ADXAdErrorNoFill]];
    }
}

- (void)adViewWillLeaveApplication:(APAdView *)view {
    ADXLogDebug(@"adViewWillLeaveApplication");
    
    if ([self.delegate respondsToSelector:@selector(didClickAd)]) {
        [self.delegate didClickAd];
    }
}


#pragma mark - AdPieAdViewDelegate

- (void)adViewDidLoad:(AdPieAdView *)adView {
    ADXLogDebug(@"adViewDidLoad");
    self.adLoaded = YES;
    
    if ([self.delegate respondsToSelector:@selector(didLoadAdView:)]) {
        [self.delegate didLoadAdView:adView];
    }
}

- (void)adView:(AdPieAdView *)adView didFailToLoadWithError:(NSError *)error {
    ADXLogError(@"adView:didFailToLoadWithError: %@", error.description);
    self.adLoaded = NO;
    
    if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
        [self.delegate didFailToLoadAdWithError:[NSError errorWithDomain:ADXAdPieErrorDomain code:ADXAdErrorNoFill]];
    }
}

- (void)adViewDidClick:(AdPieAdView *)adView {
    ADXLogDebug(@"adViewDidClick");
    
    if ([self.delegate respondsToSelector:@selector(didClickAd)]) {
        [self.delegate didClickAd];
    }
}

@end
