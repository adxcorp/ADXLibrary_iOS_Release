//
//  ADXUnityAdsBannerAd.m
//  ADXLibrary-UnityAds
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "ADXUnityAdsBannerAd.h"
#import "ADXUnityAdsAdapter.h"
#import <ADXLibrary/ADXAdLogEvent.h>

@interface ADXUnityAdsBannerAd () <UADSBannerViewDelegate>
@property (nonatomic, strong) UADSBannerView *adView;
@property (nonatomic, assign) ADXAdSize adSize;
@property (nonatomic, assign) BOOL adLoaded;
@property (nonatomic, weak) UIViewController *rootViewController;
@end

@implementation ADXUnityAdsBannerAd

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
    if ([[mediation customEventParams] count] == 0) {
        NSError *error = [NSError errorWithDomain:ADXUnityAdsErrorDomain code:ADXAdErrorNoMediationData];
        ADXDebugLogError(@"%@", error.description);
        self.adLoaded = NO;
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [ADXUnityAdsAdapter initializeSdkWithConfiguration:mediation.customEventParams
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
        [strongSelf requestAdWithAdUnitId:mediation
                                   adSize:adSize
                       rootViewController:rootViewController];
    }];
}

- (void)requestAdWithAdUnitId:(ADXMediationData *)mediation
                       adSize:(ADXAdSize)adSize
           rootViewController:(UIViewController *)rootViewController
{
    self.adLoaded = NO;
    NSString *placementId = [mediation.customEventParams objectForKey:@"placement_id"] ? : @"";
    if ([placementId length] == 0) {
        NSError *error = [NSError errorWithDomain:ADXAdNetworkUnityAds
                                             code:ADXAdErrorServerData
                                      description:@"AdUnitId or PlacementId cannot be empty."];
        ADXDebugLogError(@"%@", error.description);
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        return;
    }
    
    ADXLogDebug(@"Placement ID - %@, Banner Size - %@", placementId, NSStringFromCGSize(adSize));
    self.adSize = adSize;
    if (adSize.width <= 0.0 || adSize.height <= 0.0) {
        NSError *error = [NSError errorWithDomain:ADXAdNetworkUnityAds
                                             code:ADXAdErrorInvalidLayout
                                      description:@"UnityAds banner failed to load due to invalid ad width and/or height."];
        ADXDebugLogError(@"%@", error.description);
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        return;
    }
    
    self.rootViewController = rootViewController;
    
    /// Loads UnityAds Banner
    self.adView = [[UADSBannerView alloc] initWithPlacementId: placementId
                                                         size: CGSizeMake(adSize.width, adSize.height)];
    [self.adView setDelegate:self];
    [self.adView load];
}

- (void)unLoadBannerView {
    /// removeFromSuperview + UADSBannerView * 객체까지 nil 로 설정해야 메모리 누수가 발생하지 않는다.
    [self.adView removeFromSuperview];
    [self.adView setDelegate:nil];
    self.adView = nil;
}

- (void)dealloc {
    ADXDebugLog(@"dealloc");
    self.delegate = nil;
}


#pragma mark - UADSBannerViewDelegate methods

- (void)bannerViewDidLoad:(UADSBannerView *)bannerView {
    // Called when the banner view object finishes loading an ad.
    ADXLogEvent(ADXAdNetworkUnityAds, ADXAdTypeBanner, ADXAdEventLoaded);
    self.adLoaded = YES;
    if ([self.delegate respondsToSelector:@selector(didLoadAdView:)]) {
        [self.delegate didLoadAdView:_adView];
    }
}

- (void)bannerViewDidShow:(UADSBannerView *)bannerView {
    ADXLogEvent(ADXAdNetworkUnityAds, ADXAdTypeBanner, ADXAdEventShow);
}

- (void)bannerViewDidClick:(UADSBannerView *)bannerView {
    ADXLogEvent(ADXAdNetworkUnityAds, ADXAdTypeBanner, ADXAdEventClick);
    if ([self.delegate respondsToSelector:@selector(didClickAd)]) {
        [self.delegate didClickAd];
    }
}

- (void)bannerViewDidLeaveApplication:(UADSBannerView *)bannerView {
    ADXLogDebug(@"bannerViewDidLeaveApplication:");
}

- (void)bannerViewDidError:(UADSBannerView *)bannerView error:(UADSBannerError *)error {
    ADXLogEventError(ADXAdNetworkUnityAds, ADXAdTypeBanner, ADXAdEventLoadFailed, error);
    self.adLoaded = NO;
    if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
        [self.delegate didFailToLoadAdWithError:[NSError errorWithDomain:ADXUnityAdsErrorDomain code:ADXAdErrorNoFill]];
    }
}

@end

