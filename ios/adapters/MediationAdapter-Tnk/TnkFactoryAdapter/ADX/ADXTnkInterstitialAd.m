//
//  ADXTnkInterstitialAd.m
//  ADXLibrary-Tnk
//
//  Created by JCLEE on 2023/02/08.
//

#import "ADXTnkInterstitialAd.h"
#import "ADXTnkAdapter.h"
#import "ADXTnkUtil.h"

@interface ADXTnkInterstitialAd () <TnkAdListener>

@property (assign) BOOL adLoaded;
@property (strong) TnkInterstitialAdItem *adItem;

@end

@implementation ADXTnkInterstitialAd

@synthesize delegate;
@synthesize adNetworkInfo;

- (BOOL)isLoaded {
    return self.adLoaded;
}

- (void)dealloc {
    ADXDebugLog(@"dealloc");
    self.adItem = nil;
    self.delegate = nil;
}

- (void)loadAdWithMediationData:(ADXMediationData *)mediation {
    ADXDebugLog(@"loadAdWithMediationData");
    
    if (mediation == nil || mediation.customEventParams == nil) {
        NSError *error = [NSError errorWithDomain:ADXTnkErrorDomain
                                             code:ADXAdErrorNoMediationData];
        ADXDebugLogError(@"%@", error.description);
        self.adLoaded = NO;
        
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    // TnkHandler 정의
    typedef void(^TnkHandler)(BOOL success, NSError *_Nullable error);
    TnkHandler handler = ^(BOOL success, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (error || success == NO) {
            ADXDebugLogError(@"%@", error.description);
            strongSelf.adLoaded = NO;
            if ([strongSelf.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
                [strongSelf.delegate didFailToLoadAdWithError:error];
            }
            return;
        }
        // TnkInterstitialAdItem 초기화
        UIViewController *rootVC = [ADXTnkUtil getRootViewController];
        NSString *placementId = [mediation.customEventParams objectForKey:@"placement_id"];
        TnkInterstitialAdItem *adItem = [[TnkInterstitialAdItem alloc] initWithViewController:rootVC
                                                                                  placementId:placementId
                                                                                   adListener:strongSelf];
        // SDK 초기화 성공 시, 광고로드
        [adItem load];
    };
    
    [ADXTnkAdapter initializeSdkWithConfiguration:mediation.customEventParams
                                completionHandler:handler];
}

- (void)showAdFromRootViewController:(UIViewController *)rootViewController {
    if(self.adItem == nil || self.adLoaded == NO || rootViewController == nil){
        ADXLogDebug(@"Interstitial ad is not ready to be presented.");
        return;
    }
    if ([self.delegate respondsToSelector:@selector(willPresentScreen)]) {
        [self.delegate willPresentScreen];
    }
    [self.adItem show];
}

@end

@implementation ADXTnkInterstitialAd (TnkAdEvents)

- (void)onLoad:(id<TnkAdItem>)adItem {
    ADXLogDebug(@"onLoad");
    self.adItem = (TnkInterstitialAdItem*)adItem;
    self.adLoaded = adItem.isLoaded;
    if ([self.delegate respondsToSelector:@selector(didLoadAd)]) {
        [self.delegate didLoadAd];
    }
}

- (void)onError:(id <TnkAdItem> _Nonnull)adItem error:(enum AdError)error {
    ADXLogError(@"onError, %d", error);
    self.adLoaded = NO;
    if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
        [self.delegate didFailToLoadAdWithError:[NSError errorWithDomain:ADXTnkErrorDomain code:ADXAdErrorNoFill]];
    }
}

- (void)onClose:(id <TnkAdItem> _Nonnull)adItem type:(enum AdClose)type {
    ADXLogDebug(@"onClose");
    self.adLoaded = NO;
    if ([self.delegate respondsToSelector:@selector(willDismissScreen)]) {
        [self.delegate willDismissScreen];
    }
    if ([self.delegate respondsToSelector:@selector(didDismissScreen)]) {
        [self.delegate didDismissScreen];
    }
}

- (void)onClick:(id <TnkAdItem> _Nonnull)adItem {
    ADXLogDebug(@"onClick");
    if ([self.delegate respondsToSelector:@selector(didClickAd)]) {
        [self.delegate didClickAd];
    }
}

- (void)onShow:(id <TnkAdItem> _Nonnull)adItem {
    ADXLogDebug(@"onShow");
}

@end
