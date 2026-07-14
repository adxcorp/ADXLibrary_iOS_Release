//
//  ADXAdManagerBannerAd.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "ADXAdManagerBannerAd.h"

#import "ADXAdMobAdapter.h"
#import <ADXLibrary/ADXGdprManager.h>

@interface ADXAdManagerBannerAd () <GADBannerViewDelegate>

@property (nonatomic, strong) GAMBannerView *bannerView;
@property (nonatomic, assign) ADXAdSize adSize;
@property (nonatomic, assign) BOOL adLoaded;
@property (nonatomic, weak) UIViewController *rootViewController;

@end

@implementation ADXAdManagerBannerAd

@synthesize delegate;
@synthesize adNetworkInfo;

- (BOOL)isLoaded {
    return self.adLoaded && self.bannerView;
}

- (void)loadAdWithMediationData:(ADXMediationData *)mediation adSize:(ADXAdSize)adSize rootViewControoler:(UIViewController *)rootViewController {
    ADXDebugLog(@"loadAdWithMediationData");
    
    if (mediation == nil || mediation.customEventParams == nil) {
        NSError *error = [NSError errorWithDomain:ADXAdManagerErrorDomain code:ADXAdErrorNoMediationData];
        ADXDebugLogError(@"%@", error.description);
        self.adLoaded = NO;
        
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        
        return;
    }
    
    [ADXAdMobAdapter initializeSdkWithConfiguration:nil];
    
    NSString *adUnitId = [mediation.customEventParams objectForKey:@"adunit_id"];
    [self requestAdWithAdUnitId:adUnitId adSize:adSize rootViewController:rootViewController];
}

- (void)requestAdWithAdUnitId:(NSString *)adUnitId adSize:(ADXAdSize)adSize rootViewController:(UIViewController *)rootViewController {
    if (adUnitId == nil || adUnitId.length == 0) {
        NSError *error = [NSError errorWithDomain:ADXAdManagerErrorDomain code:ADXAdErrorServerData description:@"Ad Unit ID cannot be nil."];
        ADXDebugLogError(@"%@", error.description);
        self.adLoaded = NO;
        
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        
        return;
    }
    
    ADXLogDebug(@"requestAd Ad Unit ID - %@", adUnitId);
    
    self.adSize = adSize;
    self.rootViewController = rootViewController;
    
    if (adSize.width <= 0.0 || adSize.height <= 0.0) {
        // 유효하지 않은 사이즈
        NSError *error = [NSError errorWithDomain:ADXAdManagerErrorDomain code:ADXAdErrorInvalidLayout description:@"AdMob banner failed to load due to invalid ad width and/or height."];
        ADXDebugLogError(@"%@", error.description);
        self.adLoaded = NO;
        
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        
        return;
    }
    
    self.bannerView = [[GAMBannerView alloc] initWithAdSize:[self GADAdSizeForADXAdSize:adSize]];
    
    if (!self.rootViewController) {
        self.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    
    self.bannerView.rootViewController = self.rootViewController;
    self.bannerView.adUnitID = adUnitId;
    self.bannerView.delegate = self;
    
    [self.bannerView loadRequest:[ADXAdMobAdapter gdprGAMRequest]];
}

- (GADAdSize)GADAdSizeForADXAdSize:(ADXAdSize)adSize {
    CGFloat width = adSize.width;
    CGFloat height = adSize.height;
    
    if (width >= ADXAdSizeLeaderboard.width && height >= ADXAdSizeLeaderboard.height) {
        return GADAdSizeLeaderboard;
        
    } else if (width >= ADXAdSizeBanner.width && height >= ADXAdSizeBanner.height) {
        return GADAdSizeBanner;
        
    } else if (width >= ADXAdSizeMediumRectangle.width && height >= ADXAdSizeMediumRectangle.height) {
        return GADAdSizeMediumRectangle;
        
    } else {
        return GADAdSizeFromCGSize(CGSizeMake(width, height));
    }
}

- (void)dealloc {
    ADXDebugLog(@"dealloc");
    if (self.bannerView != nil) {
        self.bannerView.delegate = nil;
        self.bannerView = nil;
    }
    
    self.rootViewController = nil;
    self.delegate = nil;
}

#pragma mark - GADBannerViewDelegate

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    ADXLogDebug(@"bannerViewDidReceiveAd");
    self.adLoaded = YES;
    
    if ([self.delegate respondsToSelector:@selector(didLoadAdView:)]) {
        [self.delegate didLoadAdView:self.bannerView];
    }
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    ADXLogError(@"bannerView:didFailToReceiveAdWithError: %@", error.description);
    self.adLoaded = NO;
    
    if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
        [self.delegate didFailToLoadAdWithError:[NSError errorWithDomain:ADXAdManagerErrorDomain code:ADXAdErrorNoFill]];
    }
}

- (void)bannerViewDidRecordClick:(GADBannerView *)bannerView {
    ADXLogDebug(@"bannerViewDidRecordClick");
    
    if ([self.delegate respondsToSelector:@selector(didClickAd)]) {
        [self.delegate didClickAd];
    }
}

@end
