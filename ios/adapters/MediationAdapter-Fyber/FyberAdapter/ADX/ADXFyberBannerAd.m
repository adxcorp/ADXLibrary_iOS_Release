//
//  ADXFyberBannerAd.m
//  ADXLibrary-Fyber
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "ADXFyberBannerAd.h"

#import "ADXFyberAdapter.h"
#import <ADXLibrary/ADXAdError.h>

@interface ADXFyberBannerAd () <IAUnitDelegate>

@property (strong) IAAdSpot *adSpot;
@property (strong) IAViewUnitController *viewUnitController;
@property (strong) IAMRAIDContentController *mraidContentController;
@property (weak, nullable) UIViewController *rootViewController;
@property (assign) BOOL adLoaded;

@end

@implementation ADXFyberBannerAd

@synthesize delegate;
@synthesize adNetworkInfo;

- (BOOL)isLoaded {
    return self.adLoaded && self.viewUnitController;
}

- (void)loadAdWithMediationData:(ADXMediationData *)mediation adSize:(ADXAdSize)adSize rootViewControoler:(UIViewController *)rootViewController {
    ADXDebugLog(@"loadAdWithMediationData");
    
    if (mediation == nil || mediation.customEventParams == nil) {
        NSError *error = [NSError errorWithDomain:ADXFyberErrorDomain code:ADXAdErrorNoMediationData];
        ADXDebugLogError(@"%@", error.description);
        self.adLoaded = NO;
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        
        return;
    }
    
    self.rootViewController = rootViewController;
    
    __weak typeof(self) weakSelf = self;
    [ADXFyberAdapter initializeSdkWithConfiguration:mediation.customEventParams completionHandler:^(BOOL success, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (error) {
            ADXDebugLogError(@"%@", error.description);
            strongSelf.adLoaded = NO;
            if ([strongSelf.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
                [strongSelf.delegate didFailToLoadAdWithError:error];
            }
            return;
        }
        NSString *spotId = [mediation.customEventParams objectForKey:@"spot_id"];
        [strongSelf requestAdWithSpotId:spotId adSize:adSize];
    }];
}

- (void)requestAdWithSpotId:(NSString *)spotId adSize:(ADXAdSize)adSize{
    if (spotId == nil || spotId.length == 0) {
        NSError *error = [NSError errorWithDomain:ADXFyberErrorDomain code:ADXAdErrorServerData description:@"Spot ID cannot be nil."];
        ADXDebugLogError(@"%@", error.description);
        self.adLoaded = NO;
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        return;
    }
    
    ADXLogDebug(@"requestAd Spot ID - %@", spotId);
    
    self.mraidContentController = [IAMRAIDContentController build:^(id<IAMRAIDContentControllerBuilder>  _Nonnull builder) {
        
    }];
    
    __weak typeof(self) weakSelf = self;
    self.viewUnitController = [IAViewUnitController build:^(id<IAViewUnitControllerBuilder>  _Nonnull builder) {
        __strong typeof(self) strongSelf = weakSelf;
        builder.unitDelegate = strongSelf;
        [builder addSupportedContentController:strongSelf.mraidContentController];
    }];
    
    IAAdRequest *adRequest = [IAAdRequest build:^(id<IAAdRequestBuilder>  builder) {
        builder.spotID = spotId;
        builder.timeout = 10;
        builder.useSecureConnections = NO;
    }];
    
    IAAdSpot *adSpot = [IAAdSpot build:^(id<IAAdSpotBuilder> builder) {
        __strong typeof(self) strongSelf = weakSelf;
        builder.adRequest = adRequest;
        [builder addSupportedUnitController:strongSelf.viewUnitController];
    }];
    self.adSpot = adSpot;
    
    [self.adSpot fetchAdWithCompletion:^(IAAdSpot * _Nullable adSpot, IAAdModel * _Nullable adModel, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        NSError *noFillError = [NSError errorWithDomain:ADXFyberErrorDomain code:ADXAdErrorNoFill];
        if (error) {
            ADXDebugLogError(@"%@", error.description);
            strongSelf.adLoaded = NO;
            if ([strongSelf.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
                [strongSelf.delegate didFailToLoadAdWithError:noFillError];
            }
            strongSelf.adSpot = nil;
            return;
        }
        
        if (adSpot.activeUnitController != strongSelf.viewUnitController) {
            strongSelf.adLoaded = NO;
            if ([strongSelf.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
                [strongSelf.delegate didFailToLoadAdWithError:noFillError];
            }
            strongSelf.adSpot = nil;
            return;
        }
        
        UIView *adView = strongSelf.viewUnitController.adView;
        if (adView.frame.size.width < adSize.width || adView.frame.size.height < adSize.height) {
            NSError *sizeError = [NSError errorWithDomain:ADXFyberErrorDomain code:ADXAdErrorInvalidLayout];
            ADXDebugLogError(@"%@", sizeError.description);
            strongSelf.adLoaded = NO;
            if ([strongSelf.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
                [strongSelf.delegate didFailToLoadAdWithError:sizeError];
            }
            strongSelf.adSpot = nil;
            return;
        }
        
        strongSelf.adLoaded = YES;
        if ([strongSelf.delegate respondsToSelector:@selector(didLoadAdView:)]) {
            [strongSelf.delegate didLoadAdView:adView];
        }
    }];
}

- (void)dealloc {
    ADXDebugLog(@"dealloc");
    self.adSpot = nil;
    if(self.viewUnitController){
        self.viewUnitController.unitDelegate = nil;
        self.viewUnitController = nil;
    }
    if(self.mraidContentController){
        self.mraidContentController.MRAIDContentDelegate = nil;
        self.mraidContentController = nil;
    }
    self.rootViewController = nil;
    self.delegate = nil;
}


#pragma mark - IAUnitDelegate

- (UIViewController *)IAParentViewControllerForUnitController:(IAUnitController *)unitController {
    return self.rootViewController;
}

- (void)IAAdDidReceiveClick:(IAUnitController *)unitController {
    ADXLogDebug(@"IAAdDidReceiveClick");
    
    if ([self.delegate respondsToSelector:@selector(didClickAd)]) {
        [self.delegate didClickAd];
    }
}

@end
