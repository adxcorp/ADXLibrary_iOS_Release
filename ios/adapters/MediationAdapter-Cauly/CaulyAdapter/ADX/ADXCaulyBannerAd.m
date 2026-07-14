//
//  ADXCaulyBannerAd.m
//  ADXLibrary-Cauly
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "ADXCaulyBannerAd.h"

#import "ADXCaulyAdapter.h"

@interface ADXCaulyBannerAd () <CaulyAdViewDelegate>

@property (nonatomic, strong) CaulyAdView *adView;
@property (nonatomic, assign) BOOL adLoaded;

@end

@implementation ADXCaulyBannerAd

@synthesize delegate;
@synthesize adNetworkInfo;

- (BOOL)isLoaded {
    return self.adLoaded && self.adView;
}

- (void)loadAdWithMediationData:(ADXMediationData *)mediation
                         adSize:(ADXAdSize)adSize
             rootViewControoler:(UIViewController *)rootViewController
{
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
        if (error) {
            ADXDebugLogError(@"%@", error.description);
            strongSelf.adLoaded = NO;
            if ([strongSelf.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
                [strongSelf.delegate didFailToLoadAdWithError:error];
            }
            return;
        }
        [strongSelf requestAdWithMediationData:adSize];
    }];
}

- (void)requestAdWithMediationData:(ADXAdSize)adSize{
    CaulyAdSetting *adSetting = [CaulyAdSetting globalSetting];
    adSetting.animType = CaulyAnimNone; //  화면 전환 효과
    
    adSetting.adSize = CaulyAdSize_IPhone; //  광고 크기
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        adSetting.adSize = CaulyAdSize_IPadSmall;
    }
    adSetting.reloadTime = CaulyReloadTime_0;
    adSetting.useDynamicReloadTime = NO;
    adSetting.closeOnLanding = YES;
    
    // 배너 뷰의 부모 VC를 설정하면 메모리 릭이 발생하여, nil로 설정
    self.adView = [[CaulyAdView alloc] initWithParentViewController:nil];
    self.adView.frame = CGRectMake(0.0, 0.0, adSize.width, adSize.height);
    self.adView.delegate = self;
    [self.adView startBannerAdRequest];
}

- (void)dealloc {
    ADXDebugLog(@"dealloc");
    if (self.adView) {
        self.adView.delegate = nil;
        self.adView = nil;
    }
    self.delegate = nil;
}


#pragma mark - CaulyAdViewDelegate methods

- (void)didReceiveAd:(CaulyAdView *)adView isChargeableAd:(BOOL)isChargeableAd {
    ADXLogDebug(@"didReceiveAd:isChargeableAd");
    self.adLoaded = YES;
    
    if ([self.delegate respondsToSelector:@selector(didLoadAdView:)]) {
        [self.delegate didLoadAdView:adView];
    }
}

- (void)didFailToReceiveAd:(CaulyAdView *)adView errorCode:(int)errorCode errorMsg:(NSString *)errorMsg {
    ADXLogError(@"didFailToReceiveAdError: %@", errorMsg);
    self.adLoaded = NO;
    
    if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
        [self.delegate didFailToLoadAdWithError:[NSError errorWithDomain:ADXCaulyErrorDomain code:ADXAdErrorNoFill]];
    }
}

@end
