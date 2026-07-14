//
//  ADXTnkBannerAd.m
//  ADXLibrary-Tnk
//
//  Created by JCLEE on 2023/02/06.
//

#import "ADXTnkBannerAd.h"
#import "ADXTnkAdapter.h"

@interface ADXTnkBannerAd () <TnkAdListener>

@property (assign) BOOL adLoaded;
@property (strong) TnkBannerAdView *tnkAdView;
@property (strong) UIView *containerView;

@end

@implementation ADXTnkBannerAd

@synthesize delegate;
@synthesize adNetworkInfo;

- (BOOL)isLoaded {
    return self.adLoaded && self.tnkAdView;
}

- (void)dealloc {
    ADXDebugLog(@"dealloc");
    self.tnkAdView = nil;
    self.delegate = nil;
    self.containerView = nil;
}

- (void)loadAdWithMediationData:(ADXMediationData *)mediation
                         adSize:(ADXAdSize)adSize
             rootViewControoler:(UIViewController *)rootViewController
{
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
        // TnkBannerAdView 초기화
        NSString *placementId = [mediation.customEventParams objectForKey:@"placement_id"];
        TnkBannerAdView *tnkAdView = [[TnkBannerAdView alloc] initWithPlacementId:placementId
                                                                       adListener:strongSelf];
        CGRect frame = CGRectMake(0.0, 0.0, adSize.width, adSize.height);
        tnkAdView.frame = frame;
        strongSelf.containerView = [[UIView alloc] initWithFrame:frame];
        [tnkAdView setContainerView:strongSelf.containerView];
        // SDK 초기화 성공 시, 광고로드
        [tnkAdView load];
    };
    
    [ADXTnkAdapter initializeSdkWithConfiguration:mediation.customEventParams
                                completionHandler:handler];
}

@end

@implementation ADXTnkBannerAd (TnkAdEvents)

- (void)onLoad:(id<TnkAdItem>)adItem {
    ADXLogDebug(@"onLoad");
    self.tnkAdView = (TnkBannerAdView *)adItem;
    self.adLoaded = adItem.isLoaded;
    [self.tnkAdView show];
    if ([self.delegate respondsToSelector:@selector(didLoadAdView:)]) {
        [self.delegate didLoadAdView:self.containerView];
    }
}

- (void)onError:(id <TnkAdItem> _Nonnull)adItem error:(enum AdError)error {
    ADXLogError(@"onError, (%d)", error);
    self.adLoaded = NO;
    if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
        [self.delegate didFailToLoadAdWithError:[NSError errorWithDomain:ADXTnkErrorDomain code:ADXAdErrorNoFill]];
    }
}

- (void)onClose:(id <TnkAdItem> _Nonnull)adItem type:(enum AdClose)type {
    ADXLogDebug(@"onClose");
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
