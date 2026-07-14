//
//  ADXAdPieNativeAd.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "ADXAdPieNativeAd.h"

#import "ADXAdPieAdapter.h"
#import <ADXLibrary/ADXNativeAdRendering.h>
#import <ADXLibrary/ADXImageDownloadQueue.h>

#import "AdPieNativeAd.h"
#import "AdPieNativeAdView.h"
#import "AdPieResponse.h"

#import <ADXLibrary/ADXAdError.h>
#import <ADXLibrary/ADXLog.h>

@interface ADXAdPieNativeAd () <APNativeDelegate, AdPieNativeAdDelegate, AdPieNativeAdViewDelegate>

@property (strong) APNativeAd *adPieNativeAd;
@property (strong) AdPieNativeAd *nativeAd;
@property (strong) UIView<ADXNativeAdRendering> *adView;

@property (strong) Class renderingViewClass;
@property (strong) NSDictionary *imageDictionary;
@property (strong) ADXImageDownloadQueue *imageDownloadQueue;

@property (assign, getter=isReportedImpression) BOOL reportedImpression;
@property (assign) BOOL isBidResponse;
@property (assign) BOOL adLoaded;
@property (weak) ADXMediationData *adxMediationData;

@end

@implementation ADXAdPieNativeAd

@synthesize delegate;

- (BOOL)isLoaded {
    return self.adLoaded;
}

- (double)getPrice {
    // AdPie SDK 1.6.14 이하 버전 미지원 (1.6.15 이상 버전에서 지원)
    APNativeAd * apNativeAd = self.adPieNativeAd;
    if (!apNativeAd) { return 0; }
    // selector 존재 여부 확인
    SEL selector = @selector(getPrice);
    if (![apNativeAd respondsToSelector:selector]) { return 0; }
    // IMP 안전 캐스팅
    typedef double (*PriceMethod)(id, SEL);
    PriceMethod method = (PriceMethod)[apNativeAd methodForSelector:selector];
    double eCPM = method ? method(apNativeAd, selector) : 0;
    ADXLogDebug(@"eCPM: %f", eCPM);
    return eCPM;
}

- (void)loadAdWithMediationData:(ADXMediationData *)mediation renderingViewClass:(Class)renderingViewClass rootViewController:(UIViewController *)rootViewController {
    ADXDebugLog(@"loadAdWithMediationData");
    self.adxMediationData = mediation;
    
    if (renderingViewClass == nil) {
        NSError *error = [NSError errorWithDomain:ADXAdPieErrorDomain code:ADXAdErrorInvalidLayout description:@"Rendering Class is nil"];
        ADXDebugLogError(@"%@", error.description);
        self.adLoaded = NO;
        
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        
        return;
    }
    
    self.renderingViewClass = renderingViewClass;
    
    if (mediation.bidResponse != nil) {
        // bidding
        AdPieResponse *bidResponse = [[AdPieResponse alloc] initWithDictionary:mediation.bidResponse];
        if (bidResponse.result != 0 || bidResponse.count != 1 || bidResponse.adData == nil) {
            NSError *error = [NSError errorWithDomain:ADXAdPieErrorDomain code:ADXAdErrorServerData];
            ADXDebugLogError(@"%@", error.description);
            self.adLoaded = NO;
            
            if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
                [self.delegate didFailToLoadAdWithError:error];
            }
            
            return;
        }
        
        self.isBidResponse = YES;
        AdPieNativeAdData *adData = (AdPieNativeAdData *)bidResponse.adData;
        self.nativeAd = [[AdPieNativeAd alloc] init];
        self.nativeAd.delegate = self;
        [self.nativeAd loadWithAdData:adData];
        
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
            
            [strongSelf requestAdWithMediationData:mediation];
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
    self.adPieNativeAd = [[APNativeAd alloc] initWithSlotId:slotId];
    self.adPieNativeAd.delegate = self;
    
    NSString *floorPrice = [NSString stringWithFormat:@"%g", mediation.ecpm];
    [self.adPieNativeAd setExtraParameterForKey:@"floorPrice" value:floorPrice];
    [self.adPieNativeAd load];
}

- (UIView *)retrieveAdViewWithError:(NSError **)error {
    if ([self.renderingViewClass respondsToSelector:@selector(nibForAd)]) {
        self.adView = (UIView<ADXNativeAdRendering> *)[[[self.renderingViewClass nibForAd] instantiateWithOwner:nil options:nil] firstObject];
        
    } else {
        self.adView = [[self.renderingViewClass alloc] init];
    }
    
    self.adView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    AdPieNativeAdView *nativeAdView = [[AdPieNativeAdView alloc] initWithFrame:self.adView.frame];
    nativeAdView.userInteractionEnabled = NO;
    nativeAdView.nativeAd = self.isBidResponse ? self.nativeAd : self.adPieNativeAd;
    nativeAdView.delegate = self;
    [self.adView addSubview:nativeAdView];
    
    AdPieNativeAdData *data = self.isBidResponse ? self.nativeAd.adData : [[AdPieNativeAdData alloc] initWithDictionary:self.adPieNativeAd.nativeAdData.dictionary];
    NSMutableArray *clickableViews = [NSMutableArray array];
    
    if ([self.adView respondsToSelector:@selector(nativeMainTextLabel)] && self.adView.nativeMainTextLabel) {
        self.adView.nativeMainTextLabel.text = data.desc;
        [clickableViews addObject:self.adView.nativeMainTextLabel];
    }
    
    if ([self.adView respondsToSelector:@selector(nativeTitleTextLabel)] && self.adView.nativeTitleTextLabel) {
        self.adView.nativeTitleTextLabel.text = data.title;
        [clickableViews addObject:self.adView.nativeTitleTextLabel];
    }
    
    if ([self.adView respondsToSelector:@selector(nativeCallToActionButton)] && self.adView.nativeCallToActionButton) {
        [self.adView.nativeCallToActionButton setTitle:data.callToAction forState:UIControlStateNormal];
        self.adView.nativeCallToActionButton.userInteractionEnabled = YES;
        [clickableViews addObject:self.adView.nativeCallToActionButton];
    }
    
    if ([self.adView respondsToSelector:@selector(nativeIconImageView)] && self.adView.nativeIconImageView) {
        if (data.iconImageUrl != nil) {
            NSURL *url = [NSURL URLWithString:data.iconImageUrl];
            UIImageView *iconView = self.adView.nativeIconImageView;
            
            if ([self.imageDictionary objectForKey:url] != nil) {
                [iconView setImage:[self.imageDictionary objectForKey:url]];
            }
            
            iconView.userInteractionEnabled = YES;
            [clickableViews addObject:iconView];
        }
    }
    
    if ([self.adView respondsToSelector:@selector(nativeMainImageView)] && self.adView.nativeMainImageView) {
        if (data.mainImageUrl != nil) {
            NSURL *url = [NSURL URLWithString:data.mainImageUrl];
            UIImageView *mainImageView = self.adView.nativeMainImageView;
            
            if ([self.imageDictionary objectForKey:url] != nil) {
                [mainImageView setImage:[self.imageDictionary objectForKey:url]];
            }
            
            mainImageView.userInteractionEnabled = YES;
            [clickableViews addObject:mainImageView];
        }
    }
    
    [nativeAdView registerClickableViews:clickableViews];
    
    if ([self.adView respondsToSelector:@selector(nativePrivacyInformationIconImageView)] && self.adView.nativePrivacyInformationIconImageView) {
        if (data.optoutImageUrl != nil) {
            NSURL *url = [NSURL URLWithString:data.optoutImageUrl];
            UIImageView *iconView = self.adView.nativePrivacyInformationIconImageView;
            
            if ([self.imageDictionary objectForKey:url] != nil) {
                [iconView setImage:[self.imageDictionary objectForKey:url]];
            }
            
            iconView.userInteractionEnabled = YES;
            [nativeAdView registerClickablePrivacy:iconView];
        }
    }
    
    return self.adView;
}

- (void)dealloc {
    ADXDebugLog(@"dealloc");
    if (self.adPieNativeAd) {
        self.adPieNativeAd.delegate = nil;
        self.adPieNativeAd = nil;
    }
    
    if (self.nativeAd) {
        self.nativeAd.delegate = nil;
        self.nativeAd = nil;
    }
    
    self.adView = nil;
    self.delegate = nil;
    
    self.renderingViewClass = nil;
}


#pragma mark - Private Methods

- (void)precacheImagesWithURLs:(NSArray *)imageURLs completionHandler:(void (^)(NSArray * _Nullable))completionHandler {
    if (self.imageDownloadQueue == nil) {
        self.imageDownloadQueue = [[ADXImageDownloadQueue alloc] init];
    }
    
    if (imageURLs.count > 0) {
        __weak typeof(self) weakSelf = self;
        [self.imageDownloadQueue addDownloadImageURLs:imageURLs completionBlock:^(NSDictionary <NSURL *, UIImage *> *result, NSArray *errors) {
            weakSelf.imageDictionary = result;
            
            if (completionHandler) {
                completionHandler(errors);
            }
        }];
    } else {
        if (completionHandler) {
            completionHandler(nil);
        }
    }
}

- (BOOL)addURLString:(NSString *)urlString toURLArray:(NSMutableArray *)urlArray {
    if (urlString.length == 0) {
        return NO;
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    if (url) {
        [urlArray addObject:url];
        return YES;
        
    } else {
        return NO;
    }
}


#pragma mark - APNativeDelegate (for waterfall)

- (void)nativeDidLoadAd:(APNativeAd *)nativeAd {
    ADXLogDebug(@"nativeDidLoadAd");
    
    if (!self.adLoaded) {
        self.adLoaded = YES;
        
        NSMutableArray *imageURLs = [NSMutableArray array];
        if (nativeAd.nativeAdData.mainImageUrl != nil) {
            [self addURLString:nativeAd.nativeAdData.mainImageUrl toURLArray:imageURLs];
        }
        
        if (nativeAd.nativeAdData.iconImageUrl != nil) {
            [self addURLString:nativeAd.nativeAdData.iconImageUrl toURLArray:imageURLs];
        }
        
        if (nativeAd.nativeAdData.optoutImageUrl != nil) {
            [self addURLString:nativeAd.nativeAdData.optoutImageUrl toURLArray:imageURLs];
        }
        
        __weak typeof(self) weakSelf = self;
        [self precacheImagesWithURLs:imageURLs completionHandler:^(NSArray * _Nullable errors) {
            if (errors) {
                NSError *error = [NSError errorWithCode:ADXAdErrorContentLoad];
                ADXDebugLogError(@"%@", error.description);
                weakSelf.adLoaded = NO;
                
                if ([weakSelf.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
                    [weakSelf.delegate didFailToLoadAdWithError:error];
                }
                
            } else {
                if ([weakSelf.delegate respondsToSelector:@selector(didLoadAd)]) {
                    [weakSelf.delegate didLoadAd];
                }
            }
        }];
    }
}

- (void)nativeDidFailToLoadAd:(APNativeAd *)nativeAd withError:(NSError *)error {
    ADXLogError(@"nativeDidFailToLoadAd %@", error.description);
    self.adLoaded = NO;
    
    if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
        [self.delegate didFailToLoadAdWithError:[NSError errorWithDomain:ADXAdPieErrorDomain code:ADXAdErrorNoFill]];
    }
}

#pragma mark - AdPieNativeAdDelegate (for bidding)

- (void)nativeAdDidLoad:(AdPieNativeAd *)nativeAd {
    ADXLogDebug(@"nativeAdDidLoad");

    if (!self.adLoaded) {
        self.adLoaded = YES;

        NSMutableArray *imageURLs = [NSMutableArray array];
        if (self.nativeAd.adData.mainImageUrl != nil) {
            [self addURLString:self.nativeAd.adData.mainImageUrl toURLArray:imageURLs];
        }

        if (self.nativeAd.adData.iconImageUrl != nil) {
            [self addURLString:self.nativeAd.adData.iconImageUrl toURLArray:imageURLs];
        }

        if (self.nativeAd.adData.optoutImageUrl != nil) {
            [self addURLString:self.nativeAd.adData.optoutImageUrl toURLArray:imageURLs];
        }

        __weak typeof(self) weakSelf = self;
        [self precacheImagesWithURLs:imageURLs completionHandler:^(NSArray * _Nullable errors) {
            if (errors) {
                NSError *error = [NSError errorWithDomain:ADXAdPieErrorDomain code:ADXAdErrorContentLoad];
                ADXDebugLogError(@"%@", error.description);
                weakSelf.adLoaded = NO;

                if ([weakSelf.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
                    [weakSelf.delegate didFailToLoadAdWithError:error];
                }

            } else {
                if ([weakSelf.delegate respondsToSelector:@selector(didLoadAd)]) {
                    [weakSelf.delegate didLoadAd];
                }
            }
        }];
    }
}

- (void)nativeAd:(AdPieNativeAd *)nativeAd didFailToLoadWithError:(NSError *)error {
    ADXLogError(@"nativeAd:didFailToLoadWithError: %@", error.description);
    self.adLoaded = NO;

    if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
        [self.delegate didFailToLoadAdWithError:[NSError errorWithDomain:ADXAdPieErrorDomain code:ADXAdErrorNoFill]];
    }
}

#pragma mark - AdPieNativeAdViewDelegate

- (void)nativeAdViewTrackImpression:(AdPieNativeAdView *)nativeAdView {
    if (!self.isReportedImpression) {
        ADXDebugLog(@"nativeAdViewTrackImpression");
        self.reportedImpression = YES;
        
        if (self.isBidResponse) {
            [self.nativeAd fireImpression];
            
        } else {
            [self.adPieNativeAd fireImpression];
            if ([self.delegate respondsToSelector:@selector(didPaidEvent:)]) {
                double eCPM = [self.adPieNativeAd.nativeAdData price];
                ADXLogDebug(@"AdPie,onPaidEvent, eCPM: %f", eCPM);
                [self.delegate didPaidEvent:eCPM];
            } else {
                ADXLogDebug(@"AdPie,selector(didPaidEvent:) does not exist.");
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(trackImpression)]) {
            [self.delegate trackImpression];
        }
    }
}

- (void)nativeAdViewDidClick:(AdPieNativeAdView *)nativeAdView {
    ADXDebugLog(@"nativeAdViewDidClick");
    
    if (self.isBidResponse) {
        [self.nativeAd invokeDefaultAction];
    } else {
        [self.adPieNativeAd invokeDefaultAction];
    }
    
    if ([self.delegate respondsToSelector:@selector(didClickAd)]) {
        [self.delegate didClickAd];
    }
}

@end
