//
//  ADXFyberRewardedAd.m
//  ADXLibrary-Fyber
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "ADXFyberRewardedAd.h"
#import "ADXFyberAdapter.h"

#import <ADXLibrary/ADXAdError.h>

@interface ADXFyberRewardedAd () <IAUnitDelegate, IAVideoContentDelegate, IAMRAIDContentDelegate>

@property (nonatomic, strong) IAAdSpot *adSpot;
@property (nonatomic, strong) IAFullscreenUnitController *interstitialUnitController;
@property (nonatomic, strong) IAVideoContentController *videoContentController;
@property (nonatomic, strong) IAMRAIDContentController *mraidContentController;
@property (nonatomic) BOOL isVideoAvailable;
@property (nonatomic, strong) NSString *spotID;
@property (nonatomic) BOOL clickTracked;

@property (nonatomic, strong) ADXReward *reward;

@property (nonatomic, weak) UIViewController *rootViewController;

@property (nonatomic, assign) BOOL adLoaded;

@end

@implementation ADXFyberRewardedAd

@synthesize delegate;
@synthesize adNetworkInfo;

- (BOOL)isLoaded {
    return self.adLoaded && self.interstitialUnitController && self.interstitialUnitController.isReady;
}

- (void)loadAdWithMediationData:(ADXMediationData *)mediation {
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
        [strongSelf requestAdWithSpotId:spotId];
    }];
}

- (void)requestAdWithSpotId:(NSString *)spotId {
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
    __weak typeof(self) weakSelf = self;
    self.mraidContentController = [IAMRAIDContentController build:^(id<IAMRAIDContentControllerBuilder>  _Nonnull builder) {
        __strong typeof(self) strongSelf = weakSelf;
        builder.MRAIDContentDelegate = strongSelf;
    }];
    
    self.videoContentController = [IAVideoContentController build:^(id<IAVideoContentControllerBuilder>  _Nonnull builder) {
        __strong typeof(self) strongSelf = weakSelf;
        builder.videoContentDelegate = strongSelf;
    }];
    
    self.interstitialUnitController = [IAFullscreenUnitController build:^(id<IAFullscreenUnitControllerBuilder>  _Nonnull builder) {
        __strong typeof(self) strongSelf = weakSelf;
        builder.unitDelegate = strongSelf;
        [builder addSupportedContentController:strongSelf.mraidContentController];
        [builder addSupportedContentController:strongSelf.videoContentController];
    }];
    
    IAAdRequest *adRequest = [IAAdRequest build:^(id<IAAdRequestBuilder>  builder) {
        builder.spotID = spotId;
        builder.timeout = 15;
        builder.useSecureConnections = NO;
        //builder.muteAudio = YES;
        IASDKCore.sharedInstance.muteAudio = YES;
    }];
    
    self.adSpot = [IAAdSpot build:^(id<IAAdSpotBuilder> builder) {
        __strong typeof(self) strongSelf = weakSelf;
        builder.adRequest = adRequest;
        //builder.mediationType = [ADXFyberAdapter new];
        IASDKCore.sharedInstance.mediationType = [ADXFyberAdapter new];
        [builder addSupportedUnitController:strongSelf.interstitialUnitController];
    }];
    
    [self.adSpot fetchAdWithCompletion:^(IAAdSpot * _Nullable adSpot, IAAdModel * _Nullable adModel, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        NSError *noFillError = [NSError errorWithDomain:ADXFyberErrorDomain code:ADXAdErrorNoFill];
        if (error) {
            ADXDebugLogError(@"%@", error.description);
            strongSelf.adLoaded = NO;
            if ([strongSelf.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
                [strongSelf.delegate didFailToLoadAdWithError:noFillError];
            }
        } else {
            if (adSpot.activeUnitController == strongSelf.interstitialUnitController) {
                strongSelf.adLoaded = YES;
                strongSelf.isVideoAvailable = YES;
                if ([strongSelf.delegate respondsToSelector:@selector(didLoadAd)]) {
                    [strongSelf.delegate didLoadAd];
                }
            } else {
                strongSelf.adLoaded = NO;
                if ([strongSelf.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
                    [strongSelf.delegate didFailToLoadAdWithError:noFillError];
                }
            }
        }
    }];
}

- (void)showAdFromRootViewController:(UIViewController *)rootViewController {
    self.rootViewController = rootViewController;
    
    if (self.isLoaded) {
        ADXDebugLog(@"showAdFromRootViewController");
        [self.interstitialUnitController showAdAnimated:YES completion:nil];
        
    } else {
        ADXLogDebug(@"Rewarded ad is not ready to be presented.");
    }
}

- (void)dealloc {
    ADXDebugLog(@"dealloc");
    self.adSpot = nil;
    self.interstitialUnitController = nil;
    self.mraidContentController = nil;
    self.rootViewController = nil;
    self.delegate = nil;
}


#pragma mark - IAViewUnitControllerDelegate

- (UIViewController *)IAParentViewControllerForUnitController:(IAUnitController * _Nullable)unitController {
    ADXLogDebug(@"IAParentViewControllerForUnitController");
    
    return self.rootViewController;
}

- (void)IAAdDidReceiveClick:(IAUnitController *)unitController {
    ADXLogDebug(@"IAAdDidReceiveClick");
    
    if ([self.delegate respondsToSelector:@selector(didClickAd)]) {
        [self.delegate didClickAd];
    }
}

- (void)IAAdWillLogImpression:(IAUnitController *)unitController {
    ADXLogDebug(@"IAAdWillLogImpression");
    
    if ([self.delegate respondsToSelector:@selector(willPresentScreen)]) {
        [self.delegate willPresentScreen];
    }
}

- (void)IAAdDidReward:(IAUnitController *)unitController {
    ADXLogDebug(@"IAAdDidReward");
    
    if ([self.delegate respondsToSelector:@selector(didRewardUserWithReward:)]) {
        ADXReward *reward = [[ADXReward alloc] initWithCurrencyType:ADXRewardCurrencyType
                                                             amount:@(ADXRewardCurrencyAmount)];
        [self.delegate didRewardUserWithReward:reward];
    }
}

- (void)IAUnitControllerWillDismissFullscreen:(IAUnitController * _Nullable)unitController {
    ADXLogDebug(@"IAUnitControllerWillDismissFullscreen");
    
    if ([self.delegate respondsToSelector:@selector(willDismissScreen)]) {
        [self.delegate willDismissScreen];
    }
}

- (void)IAUnitControllerDidDismissFullscreen:(IAUnitController * _Nullable)unitController {
    ADXLogDebug(@"IAUnitControllerDidDismissFullscreen");
    self.adLoaded = NO;
    
    if ([self.delegate respondsToSelector:@selector(didDismissScreen)]) {
        [self.delegate didDismissScreen];
    }
}

- (void)IAAdDidExpire:(IAUnitController * _Nullable)unitController {
    NSError *error = [NSError errorWithDomain:ADXFyberErrorDomain code:ADXAdErrorContentLoad description:@"Fyber ad is expired."];
    ADXLogError(@"IAAdDidExpire: %@",error.description);
    self.adLoaded = NO;
    
    if ([self.delegate respondsToSelector:@selector(didFailToShowAdWithError:)]) {
        [self.delegate didFailToShowAdWithError:error];
    }
}


#pragma mark - IAVideoContentDelegate

- (void)IAVideoCompleted:(IAVideoContentController * _Nullable)contentController {
    ADXLogDebug(@"IAVideoCompleted");
    
    if ([self.delegate respondsToSelector:@selector(didEndVideo)]) {
        [self.delegate didEndVideo];
    }
}

- (void)IAVideoContentController:(IAVideoContentController * _Nullable)contentController videoInterruptedWithError:(NSError *)error {
    ADXLogError(@"IAVideoContentController:videoInterruptedWithError: %@", error.description);
    self.adLoaded = NO;
    
    if ([self.delegate respondsToSelector:@selector(didFailToShowAdWithError:)]) {
        [self.delegate didFailToShowAdWithError:error];
    }
}

- (void)IAVideoContentController:(IAVideoContentController * _Nullable)contentController videoDurationUpdated:(NSTimeInterval)videoDuration {
    ADXLogDebug(@"IAVideoContentController:videoDurationUpdated");
    ADXLogDebug(@"video duration updated: %.02lf", videoDuration);
}

@end
