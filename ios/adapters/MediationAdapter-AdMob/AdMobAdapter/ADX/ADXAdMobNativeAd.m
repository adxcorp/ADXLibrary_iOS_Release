//
//  ADXAdMobNativeAd.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "ADXAdMobNativeAd.h"

#import "ADXAdMobAdapter.h"
#import <ADXLibrary/ADXNativeAd.h>
#import <ADXLibrary/ADXNativeAdRendering.h>
#import <ADXLibrary/UIView+ADXAdditions.h>

@interface ADXAdMobNativeAd () <GADNativeAdLoaderDelegate, GADNativeAdDelegate>

@property (nonatomic, strong) GADAdLoader *adLoader;
@property (nonatomic, strong) GADNativeAd *nativeAd;

@property (nonatomic, strong) UIView<ADXNativeAdRendering> *adView;
@property (nonatomic, strong) Class renderingViewClass;

@property (nonatomic, assign) BOOL adLoaded;
@property (weak) ADXMediationData *adxMediationData;

@end

@implementation ADXAdMobNativeAd

@synthesize delegate;

- (BOOL)isLoaded {
    return self.adLoaded && self.nativeAd;
}

- (void)loadAdWithMediationData:(ADXMediationData *)mediation renderingViewClass:(Class)renderingViewClass rootViewController:(UIViewController *)rootViewController {
    ADXDebugLog(@"loadAdWithMediationData");
    self.adLoaded = NO;
    
    if (mediation == nil || mediation.customEventParams == nil) {
        NSError *error = [NSError errorWithDomain:ADXAdMobErrorDomain code:ADXAdErrorNoMediationData];
        ADXDebugLogError(@"%@", error.description);
        
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        
        return;
    }
    
    if (renderingViewClass == nil) {
        NSError *error = [NSError errorWithDomain:ADXAdMobErrorDomain code:ADXAdErrorInvalidLayout description:@"Rendering Class is nil"];
        ADXDebugLogError(@"%@", error.description);
        self.adLoaded = NO;
        
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        
        return;
    }
    
    self.adxMediationData = mediation;
    [ADXAdMobAdapter initializeSdkWithConfiguration:nil];
    
    NSString *adUnitId = [mediation.customEventParams objectForKey:@"adunit_id"];
    [self requestAdWithAdUnitId:adUnitId renderingViewClass:renderingViewClass rootViewController:rootViewController];
}

- (void)requestAdWithAdUnitId:(NSString *)adUnitId renderingViewClass:(Class)renderingViewClass rootViewController:(UIViewController *)rootViewController {
    if (adUnitId == nil || adUnitId.length == 0) {
        NSError *error = [NSError errorWithDomain:ADXAdMobErrorDomain code:ADXAdErrorServerData description:@"Ad Unit ID cannot be nil."];
        ADXDebugLogError(@"%@", error.description);
        self.adLoaded = NO;
        
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        
        return;
    }
    
    ADXLogDebug(@"requestAd Ad Unit ID - %@", adUnitId);
    
    self.renderingViewClass = renderingViewClass;
    
    GADRequest *request = [ADXAdMobAdapter gdprGADRequest];
    
    GADNativeAdImageAdLoaderOptions *nativeAdImageLoaderOptions = [[GADNativeAdImageAdLoaderOptions alloc] init];
    nativeAdImageLoaderOptions.shouldRequestMultipleImages = NO;
    
    self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:adUnitId
                                       rootViewController:rootViewController
                                                  adTypes:@[ GADAdLoaderAdTypeNative ]
                                                  options:@[ nativeAdImageLoaderOptions ]];
    self.adLoader.delegate = self;
    [self.adLoader loadRequest:request];
}

- (UIView *)retrieveAdViewWithError:(NSError **)error {
    if ([self.renderingViewClass respondsToSelector:@selector(nibForAd)]) {
        self.adView = (UIView<ADXNativeAdRendering> *)[[[self.renderingViewClass nibForAd] instantiateWithOwner:nil options:nil] firstObject];
        
    } else {
        self.adView = [[self.renderingViewClass alloc] init];
    }
    
    self.adView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    GADNativeAdView *nativeAdView = [[GADNativeAdView alloc] init];
    
    GADAdChoicesView *adChoicesView = [[GADAdChoicesView alloc] initWithFrame:CGRectZero];
    adChoicesView.userInteractionEnabled = NO;
    nativeAdView.adChoicesView = adChoicesView;
    
    GADMediaView *mediaView = [[GADMediaView alloc] initWithFrame:CGRectZero];
    nativeAdView.mediaView = mediaView;
    
    UILabel *headlineView = [[UILabel alloc] initWithFrame:CGRectZero];
    headlineView.text = self.nativeAd.headline;
    headlineView.textColor = [UIColor clearColor];
    nativeAdView.headlineView = headlineView;
    
    UILabel *bodyView = [[UILabel alloc] initWithFrame:CGRectZero];
    bodyView.text = self.nativeAd.body;
    bodyView.textColor = [UIColor clearColor];
    nativeAdView.bodyView = bodyView;
    
    UIButton *callToActionView = [[UIButton alloc] initWithFrame:CGRectZero];
    [callToActionView setTitle:self.nativeAd.callToAction forState:UIControlStateNormal];
    [callToActionView setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    nativeAdView.callToActionView = callToActionView;
    
    UIImageView *mainMediaImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    mainMediaImageView.image = self.nativeAd.images.firstObject.image;
    nativeAdView.imageView = mainMediaImageView;
    
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
    iconView.image = self.nativeAd.icon.image;
    nativeAdView.iconView = iconView;
    
    nativeAdView.nativeAd = self.nativeAd;
    
    nativeAdView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [nativeAdView addSubview:self.adView];
    [self.adView fillSuperview];
    
    if ([self.adView respondsToSelector:@selector(nativeTitleTextLabel)] && self.adView.nativeTitleTextLabel) {
        [self.adView.nativeTitleTextLabel addSubview:nativeAdView.headlineView];
        self.adView.nativeTitleTextLabel.text = self.nativeAd.headline;
        [nativeAdView.headlineView fillSuperview];
    }
    
    if ([self.adView respondsToSelector:@selector(nativeMainTextLabel)] && self.adView.nativeMainTextLabel) {
        [self.adView.nativeMainTextLabel addSubview:nativeAdView.bodyView];
        self.adView.nativeMainTextLabel.text = self.nativeAd.body;
        [nativeAdView.bodyView fillSuperview];
    }
    
    if ([self.adView respondsToSelector:@selector(nativeCallToActionButton)] && self.adView.nativeCallToActionButton) {
        nativeAdView.callToActionView.userInteractionEnabled = YES;
        [self.adView.nativeCallToActionButton addSubview:nativeAdView.callToActionView];
        [self.adView.nativeCallToActionButton setTitle:self.nativeAd.callToAction forState:UIControlStateNormal];
        self.adView.nativeCallToActionButton.userInteractionEnabled = NO;
        [nativeAdView.callToActionView fillSuperview];
    }
    
    if ([self.adView respondsToSelector:@selector(nativeIconImageView)] && self.adView.nativeIconImageView) {
        [self.adView.nativeIconImageView addSubview:nativeAdView.iconView];
        [nativeAdView.iconView fillSuperview];
    }
    
    if ([self.adView respondsToSelector:@selector(nativePrivacyInformationIconImageView)] && self.adView.nativePrivacyInformationIconImageView) {
        [self.adView.nativePrivacyInformationIconImageView addSubview:nativeAdView.adChoicesView];
        UIView * view = [[nativeAdView.adChoicesView subviews] firstObject];
        // Pangle Native 가 포함되어서 들어오는 경우, adChoicesView의 서브 뷰에 UIImageView가 존재하고 너비와 높이에 대한 제약이 다양하게 설정되어서 들어 옴.
        [self changePrivacyIconImageViewConstraints:view];
        [nativeAdView.adChoicesView fillSuperview];
    }
    
    if ([self.adView respondsToSelector:@selector(nativeMainImageView)] && self.adView.nativeMainImageView) {
        [self.adView.nativeMainImageView addSubview:nativeAdView.mediaView];
        [nativeAdView.mediaView fillSuperview];
        
        self.adView.nativeMainImageView.userInteractionEnabled = YES;
    } else {
        nativeAdView.mediaView = nil;
    }
    
    return nativeAdView;
}

- (void)changePrivacyIconImageViewConstraints:(UIView *)view {
    if(view == nil) { return; }
    if([view isKindOfClass:[UIImageView class]] == NO) { return; }
    
    view.translatesAutoresizingMaskIntoConstraints = NO;
    // 기존 너비, 높이 제약 비활성화
    for (NSLayoutConstraint *constraint in view.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeWidth
            || constraint.firstAttribute == NSLayoutAttributeHeight)
        {
            constraint.active = NO;
        }
    }
    // 부모 뷰 크기와 동일하도록 제약
    [view fillSuperview];
}

- (void)dealloc {
    ADXDebugLog(@"dealloc");
    if (self.nativeAd) {
        self.nativeAd.delegate = nil;
        self.nativeAd = nil;
    }
    
    self.adView = nil;
    self.delegate = nil;
    
    self.renderingViewClass = nil;
}

#pragma mark - GADNativeAdLoaderDelegate

- (void)adLoader:(nonnull GADAdLoader *)adLoader didReceiveNativeAd:(nonnull GADNativeAd *)nativeAd {
    ADXLogDebug(@"adLoader:didReceiveNativeAd");
    
    if (!self.adLoaded) {
        if (![self isValidNativeAd:nativeAd]) {
            NSError *error = [NSError errorWithDomain:ADXAdMobErrorDomain code:ADXAdErrorInvalidLayout description:@"Native ad is missing one or more required assets, failing the request"];
            ADXDebugLogError(@"%@", error.description);
            self.adLoaded = NO;
            
            if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
                [self.delegate didFailToLoadAdWithError:[NSError errorWithDomain:ADXAdMobErrorDomain code:ADXAdErrorNoFill]];
            }
            
            return;
        }
        
        self.adLoaded = YES;
        self.nativeAd = nativeAd;
        self.nativeAd.delegate = self;
        
        __weak typeof(self) weakSelf = self;
        self.nativeAd.paidEventHandler = ^(GADAdValue * _Nonnull value) {
            __typeof__(self) strongSelf = weakSelf;
            if(!strongSelf) { return; }
            if(![strongSelf adxMediationData]) { return; }
            // Extract the impression-level ad revenue data.
            ADXDebugLog(@"admob, paidEventHandler, ecpm: %f (%d)", [value.value doubleValue] * 1000, value.precision);
            double revenue = [value.value doubleValue] >= 0 ? [value.value doubleValue] * 1000 : strongSelf.adxMediationData.ecpm;
            if ([strongSelf.delegate respondsToSelector:@selector(didPaidEvent:)]) {
                [strongSelf.delegate didPaidEvent:revenue];
            }
        };
        
        if ([self.delegate respondsToSelector:@selector(didLoadAd)]) {
            [self.delegate didLoadAd];;
        }
    }
}

- (void)adLoader:(nonnull GADAdLoader *)adLoader didFailToReceiveAdWithError:(nonnull NSError *)error {
    ADXLogError(@"adLoader:didFailToReceiveAdWithError: %@", error.description);
    self.adLoaded = NO;
    
    if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
        [self.delegate didFailToLoadAdWithError:error];
    }
}


#pragma mark - GADNativeAdDelegate

- (void)nativeAdDidRecordImpression:(GADNativeAd *)nativeAd {
    ADXLogDebug(@"nativeAdDidRecordImpression");
    [ADXAdMobAdapter printAdNetworkResponseInfo:[nativeAd responseInfo]];
    if ([self.delegate respondsToSelector:@selector(trackImpression)]) {
        [self.delegate trackImpression];
    }
}

- (void)nativeAdDidRecordClick:(GADNativeAd *)nativeAd {
    ADXLogDebug(@"nativeAdDidRecordClick");
    
    if ([self.delegate respondsToSelector:@selector(didClickAd)]) {
        [self.delegate didClickAd];
    }
}

#pragma mark - Private Methods

- (BOOL)isValidNativeAd:(GADNativeAd *)nativeAd {
    return (nativeAd.headline && nativeAd.body && nativeAd.icon && nativeAd.callToAction);
}

@end
