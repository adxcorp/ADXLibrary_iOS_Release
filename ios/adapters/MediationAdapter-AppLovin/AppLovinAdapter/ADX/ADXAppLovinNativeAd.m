//
//  ADXAppLovinNativeAd.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "ADXAppLovinNativeAd.h"

#import "ADXAppLovinAdapter.h"

#import <ADXLibrary/ADXNativeAd.h>
#import <ADXLibrary/ADXNativeAdRendering.h>
#import "GADMAdapterAppLovinUtils.h"

@interface ADXAppLovinNativeAd () <MANativeAdDelegate, MAAdRevenueDelegate>

@property (strong) MANativeAdLoader *nativeAdLoader;
@property (strong) MAAd *nativeAd;
@property (strong) MANativeAdView *nativeAdView;

@property (strong) UIView<ADXNativeAdRendering> *adView;
@property (strong) Class renderingViewClass;

@property (assign) BOOL adLoaded;
@property (weak) ADXMediationData *adxMediationData;

@end

@implementation ADXAppLovinNativeAd

@synthesize delegate;

- (BOOL)isLoaded {
    return self.adLoaded && self.nativeAd;
}

- (void)loadAdWithMediationData:(ADXMediationData *)mediation renderingViewClass:(Class)renderingViewClass rootViewController:(UIViewController *)rootViewController {
    ADXDebugLog(@"loadAdWithMediationData");
    self.adLoaded = NO;
    
    if (mediation == nil || [GADMAdapterAppLovinUtils isChildUser]) {
        NSError *error = [NSError errorWithDomain:ADXAppLovinErrorDomain code:ADXAdErrorNoMediationData];
        ADXDebugLogError(@"%@", error.description);
        
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        
        return;
    }
    
    self.adxMediationData = mediation;
    
    __weak typeof(self) weakSelf = self;
    [ADXAppLovinAdapter initializeSdkWithConfiguration:nil completionHandler:^(BOOL success, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        if (error) {
            ADXDebugLogError(@"%@", error.description);
            strongSelf.adLoaded = NO;
            
            if ([strongSelf.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
                [strongSelf.delegate didFailToLoadAdWithError:error];
            }
            return;
        }
        
        [strongSelf requestAdWithMediationData:mediation renderingViewClass:renderingViewClass];
    }];
}

- (void)requestAdWithMediationData:(ADXMediationData *)mediation renderingViewClass:(Class)renderingViewClass {
    self.adxMediationData = mediation;
    
    NSString *adUnitId = [mediation.customEventParams objectForKey:@"adunit_id"];
    
    if (mediation.enableBiddingKit) {
        adUnitId = mediation.biddingKitAdUnitId;
        
    } else if (adUnitId == nil || adUnitId.length == 0) {
        adUnitId = [mediation.customEventParams objectForKey:@"zone_id"];
    }
    
    if (adUnitId == nil || adUnitId.length == 0) {
        NSError *error = [NSError errorWithDomain:ADXAppLovinErrorDomain code:ADXAdErrorServerData description:@"Ad Unit ID cannot be nil."];
        ADXDebugLogError(@"%@", error.description);
        self.adLoaded = NO;
        
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        
        return;
    }
    
    ALSdk *sdk = [ADXAppLovinAdapter appLovinSdk];
    
    if (!sdk.initialized) {
        NSError *error = [NSError errorWithDomain:ADXAppLovinErrorDomain code:ADXAdErrorSdkNotInitialize description:@"AppLovin initialization failed."];
        ADXDebugLogError(@"%@", error.description);
        self.adLoaded = NO;
        
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        
        return;
    }
    
    if (renderingViewClass == nil) {
        NSError *error = [NSError errorWithDomain:ADXAppLovinErrorDomain code:ADXAdErrorInvalidLayout description:@"Rendering Class is nil"];
        ADXDebugLogError(@"%@", error.description);
        self.adLoaded = NO;
        
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        
        return;
    }
    
    self.renderingViewClass = renderingViewClass;
    if ([self.renderingViewClass respondsToSelector:@selector(nibForAd)]) {
        self.adView = (UIView<ADXNativeAdRendering> *)[[[self.renderingViewClass nibForAd] instantiateWithOwner:nil options:nil] firstObject];
    } else {
        self.adView = [[self.renderingViewClass alloc] init];
    }
    
    self.adView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    if ([self.adView respondsToSelector:@selector(nativeTitleTextLabel)] && self.adView.nativeTitleTextLabel) {
        [self.adView.nativeTitleTextLabel setTag:1000];
        self.adView.nativeTitleTextLabel.userInteractionEnabled = YES;
    }
    
    if ([self.adView respondsToSelector:@selector(nativeMainTextLabel)] && self.adView.nativeMainTextLabel) {
        [self.adView.nativeMainTextLabel setTag:1001];
        self.adView.nativeMainTextLabel.userInteractionEnabled = YES;
    }
    
    if ([self.adView respondsToSelector:@selector(nativeCallToActionButton)] && self.adView.nativeCallToActionButton) {
        [self.adView.nativeCallToActionButton setTag:1002];
    }
    
    if ([self.adView respondsToSelector:@selector(nativeIconImageView)] && self.adView.nativeIconImageView) {
        [self.adView.nativeIconImageView setTag:1003];
        self.adView.nativeIconImageView.userInteractionEnabled = YES;
    }
    
    if ([self.adView respondsToSelector:@selector(nativeMainImageView)] && self.adView.nativeMainImageView) {
        [self.adView.nativeMainImageView setTag:1004];
        self.adView.nativeMainImageView.userInteractionEnabled = YES;
    }
    
    if ([self.adView respondsToSelector:@selector(nativeSponsoredByCompanyTextLabel)] && self.adView.nativeSponsoredByCompanyTextLabel) {
        [self.adView.nativeSponsoredByCompanyTextLabel setTag:1005];
        self.adView.nativeSponsoredByCompanyTextLabel.userInteractionEnabled = YES;
    }
    
    if ([self.adView respondsToSelector:@selector(nativePrivacyInformationIconImageView)] && self.adView.nativePrivacyInformationIconImageView) {
        [self.adView.nativePrivacyInformationIconImageView setTag:1006];
        self.adView.nativePrivacyInformationIconImageView.userInteractionEnabled = YES;
    }
    
    MANativeAdViewBinder *binder = [[MANativeAdViewBinder alloc] initWithBuilderBlock:^(MANativeAdViewBinderBuilder *builder) {
        builder.titleLabelTag = 1000;
        builder.bodyLabelTag = 1001;
        builder.callToActionButtonTag = 1002;
        builder.iconImageViewTag = 1003;
        builder.mediaContentViewTag = 1004;
        builder.advertiserLabelTag = 1005;
        builder.optionsContentViewTag = 1006;
    }];
    
    self.nativeAdLoader = [[MANativeAdLoader alloc] initWithAdUnitIdentifier:adUnitId sdk:sdk];
    self.nativeAdLoader.nativeAdDelegate = self;
    self.nativeAdLoader.revenueDelegate = self;
    
    self.nativeAdView = [[MANativeAdView alloc] initWithFrame:self.adView.frame];
    self.nativeAdView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.nativeAdView addSubview:self.adView];
    [self.nativeAdView bindViewsWithAdViewBinder:binder];
    [self.nativeAdLoader setExtraParameterForKey:@"disable_auto_retries" value:@"true"];
    
    if (mediation.enableBiddingKit) {
        NSString *ecpm = [NSString stringWithFormat:@"%g", mediation.ecpm];
        // bidding using applovin custom adapter
        ADXLogDebug(@"biddingPlatform - %@", [mediation biddingPlatform]);
        if([[mediation biddingPlatform] isEqualToString:@"max"]){
            NSMutableDictionary * dictionary = [@{
                @"format" : @(ADX_AD_FORMAT_NATIVE),
                @"ecpm" : ecpm,
                @"enable_bidding" : @1,
            } mutableCopy];
            if(self.loadedAd) { dictionary[@"is_native_ad_loaded"] = @1; };
            // setLocalExtraParameterForKey
            [self.nativeAdLoader setLocalExtraParameterForKey:@"adx_local_data" value:dictionary];
        } else {
            // bidding kit
            [self.nativeAdLoader setExtraParameterForKey:ADXAppLovinBiddingKitKey value:ecpm];
        }
        ADXLogDebug(@"[Bidding] requestAd - %@", adUnitId);
        
    } else {
        ADXLogDebug(@"requestAd - %@", adUnitId);
    }
    
    [self.nativeAdLoader loadAdIntoAdView:self.nativeAdView];
}

- (UIView *)retrieveAdViewWithError:(NSError **)error {
    return self.nativeAdView;
}

- (void)dealloc {
    [self releaseNativeAd];
}

- (void)releaseNativeAd {
    if (self.nativeAd && self.nativeAdLoader) {
        [self.nativeAdLoader destroyAd:self.nativeAd];
    }
    if (self.nativeAdLoader) {
        [self.nativeAdLoader setLocalExtraParameterForKey:@"adx_local_data" value:@{}];
        [self.nativeAdLoader setNativeAdDelegate:nil];
    }
    self.nativeAdView = nil;
    self.adView = nil;
}


#pragma mark - MANativeAdDelegate

- (void)didLoadNativeAd:(MANativeAdView *)nativeAdView forAd:(MAAd *)ad {
    if([[ad networkName] isEqualToString:@"ADX"] && [self.adxMediationData enableBiddingKit]) {
        ADXLogDebug(@"didFailToLoadAdWithError, (REASON: ADX CUSTOM ADAPTER)");
        /// ADX Custom Adapter (Bidding Kit 대체용)에 의해서 로드 성공 이벤트가 발생할 경우, 'didFailToLoadAdWithError' 를 발생시킴
        /// 이유:  AppLoin 어댑터를 통해서 Native 광고 렌더링용 데이터를 처리하는데 어려움이 있으므로,  이 클래스(앱러빈)가 아닌,
        /// 이전 네이티브 광고 로드에 성공했던 오리지날 클래스로 광고 이벤트를 처리한다.
        self.nativeAd = ad; // destroyAd 메소드를 호출할 수 있도록, MAAd 객체 'ad' 할당
        [self releaseNativeAd];
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:[NSError errorWithDomain:ADXAppLovinErrorDomain code:ADXAdErrorNoFill]];
        }
        return;
    }
    
    ADXLogDebug(@"didLoadNativeAd");
    if (!self.adLoaded) {
        if (self.nativeAd) {
            [self releaseNativeAd];
        }
        
        self.adLoaded = YES;
        
        self.nativeAd = ad;
        self.nativeAdView = nativeAdView;
        
        if ([self.delegate respondsToSelector:@selector(didLoadAd)]) {
            [self.delegate didLoadAd];
        }
    }
}

- (void)didFailToLoadNativeAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error {
    ADXLogError(@"didFailToLoadNativeAdForAdUnitIdentifier: %@ / Code=%ld %@", adUnitIdentifier, error.code, error.message);
    self.adLoaded = NO;
    [self releaseNativeAd];
    if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
        [self.delegate didFailToLoadAdWithError:[NSError errorWithDomain:ADXAppLovinErrorDomain code:ADXAdErrorNoFill]];
    }
}

- (void)didClickNativeAd:(MAAd *)ad {
    ADXLogDebug(@"didClickNativeAd");
    
    if ([self.delegate respondsToSelector:@selector(didClickAd)]) {
        [self.delegate didClickAd];
    }
}

- (void)didPayRevenueForAd:(MAAd *)ad {
    ADXLogDebug(@"didPayRevenueForAd");
    [ADXAppLovinAdapter printAdNetworkResponseInfo:ad];
    
    if ([self.delegate respondsToSelector:@selector(trackImpression)]) {
        [self.delegate trackImpression];
    }
    
    // The value of ad.revenue may be -1 in the case of an error.
    // The ad’s revenue amount. In the case where no revenue amount exists, or it is not available yet, will return a value of 0.
    double revenue = ad.revenue >= 0 ? ad.revenue * 1000 : self.adxMediationData.ecpm; // In USD
    /**
     * The precision of the revenue value for this ad.
     *
     * Possible values are:
     * - "publisher_defined" - If the revenue is the price assigned to the line item by the publisher.
     * - "exact" - If the revenue is the resulting price of a real-time auction.
     * - "estimated" - If the revenue is the price obtained by auto-CPM.
     * - "undefined" - If we do not have permission from the ad network to share impression-level data.
     */
    NSString *revenuePrecision = ad.revenuePrecision;
    NSString *networkName = ad.networkName;
    ADXLogDebug(@"didPayRevenueForAd, %@ ecpm: %f, %@", networkName, revenue, revenuePrecision);
    if ([self.delegate respondsToSelector:@selector(didPaidEvent:)]) {
        [self.delegate didPaidEvent:revenue];
    }
}

@end
