//
//  VungleInterstitialCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <VungleSDK/VungleSDK.h>
#if __has_include("MoPub.h")
    #import "MPLogging.h"
    #import "MoPub.h"
#endif
#import "VungleAdapterConfiguration.h"
#import "VungleInterstitialCustomEvent.h"
#import "VungleRouter.h"

#import "ADXLogUtil.h"

// If you need to play ads with vungle options, you may modify playVungleAdFromRootViewController and create an options dictionary and call the playAd:withOptions: method on the vungle SDK.

@interface VungleInterstitialCustomEvent () <VungleRouterDelegate>

@property (nonatomic) BOOL isAdLoaded;
@property (nonatomic, copy) NSString *placementId;
@property (nonatomic, copy) NSDictionary *options;

@end

@implementation VungleInterstitialCustomEvent
@dynamic delegate;
@dynamic localExtras;
@dynamic hasAdAvailable;

#pragma mark - MPFullscreenAdAdapter Override

- (BOOL)hasAdAvailable {
    return [[VungleRouter sharedRouter] isAdAvailableForPlacementId:self.placementId];
}

- (BOOL)isRewardExpected {
    return NO;
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    ADXLogEvent(ADX_PLATFORM_VUNGLE, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_LOAD);
    
    self.placementId = [info objectForKey:kVunglePlacementIdKey];
    
    // Cache the initialization parameters
    [VungleAdapterConfiguration updateInitializationParameters:info];
    
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getPlacementID]);
    [[VungleRouter sharedRouter] requestInterstitialAdWithCustomEventInfo:info delegate:self];
}

- (void)presentAdFromViewController:(UIViewController *)viewController
{
    if ([[VungleRouter sharedRouter] isAdAvailableForPlacementId:self.placementId]) {
        
        if (self.options) {
            // In the event that options have been updated
            self.options = nil;
        }
        
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        
        if (self.localExtras != nil && [self.localExtras count] > 0) {
            NSString *ordinal = [self.localExtras objectForKey:kVungleOrdinal];
            if (ordinal != nil) {
                NSNumber *ordinalPlaceholder = [NSNumber numberWithLongLong:[ordinal longLongValue]];
                NSUInteger ordinal = ordinalPlaceholder.unsignedIntegerValue;
                if (ordinal > 0) {
                    options[VunglePlayAdOptionKeyOrdinal] = @(ordinal);
                }
            }
            
            NSString *flexViewAutoDismissSeconds = [self.localExtras objectForKey:kVungleFlexViewAutoDismissSeconds];
            if (flexViewAutoDismissSeconds != nil) {
                NSTimeInterval flexDismissTime = [flexViewAutoDismissSeconds floatValue];
                if (flexDismissTime > 0) {
                    options[VunglePlayAdOptionKeyFlexViewAutoDismissSeconds] = @(flexDismissTime);
                }
            }
            
            NSString *muted = [self.localExtras objectForKey:kVungleStartMuted];
            if ( muted != nil) {
                BOOL startMutedPlaceholder = [muted boolValue];
                options[VunglePlayAdOptionKeyStartMuted] = @(startMutedPlaceholder);
            }
            
            NSString *supportedOrientation = [self.localExtras objectForKey:kVungleSupportedOrientations];
            if ( supportedOrientation != nil) {
                [self setOrientationOptions:options supportedOrientation:supportedOrientation];
            } else if ([VungleAdapterConfiguration orientations] != nil) {
                [self setOrientationOptions:options supportedOrientation:[VungleAdapterConfiguration orientations]];
            }
            
        } else if ([VungleAdapterConfiguration orientations] != nil) {
            [self setOrientationOptions:options supportedOrientation:[VungleAdapterConfiguration orientations]];
        }

        self.options = options.count ? options : nil;
        
        MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.placementId);
        [[VungleRouter sharedRouter] presentInterstitialAdFromViewController:viewController options:self.options forPlacementId:self.placementId];
    } else {
        NSError *error = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:@"Failed to show Vungle video interstitial: Vungle now claims that there is no available video ad."];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getPlacementID]);
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
    }
}

- (void)setOrientationOptions:(NSMutableDictionary *)options supportedOrientation:(NSString *)supportedOrientation
{
    int appOrientation = [supportedOrientation intValue];
    NSNumber *orientations = @(UIInterfaceOrientationMaskAll);
    
    if (appOrientation == 1) {
        orientations = @(UIInterfaceOrientationMaskLandscape);
    } else if (appOrientation == 2) {
        orientations = @(UIInterfaceOrientationMaskPortrait);
    }
    
    options[VunglePlayAdOptionKeyOrientations] = orientations;
}

- (void)cleanUp
{
    [[VungleRouter sharedRouter] clearDelegateForPlacementId:self.placementId];
}

#pragma mark - VungleRouterDelegate

- (void)vungleAdDidLoad
{
    ADXLogEvent(ADX_PLATFORM_VUNGLE, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_LOAD_SUCCESS);
    
    if (self.isAdLoaded) {
        return;
    }
    
    self.isAdLoaded = YES;
    
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)vungleAdWillAppear
{
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    [self.delegate fullscreenAdAdapterAdWillAppear:self];
}

- (void)vungleAdDidAppear
{
    ADXLogEvent(ADX_PLATFORM_VUNGLE, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_IMPRESSION);
    
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    [self.delegate fullscreenAdAdapterAdDidAppear:self];
    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
}

- (void)vungleAdWillDisappear
{
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
}

- (void)vungleAdDidDisappear
{
    ADXLogEvent(ADX_PLATFORM_VUNGLE, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_CLOSED);
    
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
    
    // Signal that the fullscreen ad is closing and the state should be reset.
    // `fullscreenAdAdapterAdDidDismiss:` was introduced in MoPub SDK 5.15.0.
    if ([self.delegate respondsToSelector:@selector(fullscreenAdAdapterAdDidDismiss:)]) {
        [self.delegate fullscreenAdAdapterAdDidDismiss:self];
    }
    
    [self cleanUp];
    
}

- (void)vungleAdTrackClick
{
    ADXLogEvent(ADX_PLATFORM_VUNGLE, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_CLICK);
    
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    [self.delegate fullscreenAdAdapterDidTrackClick:self];
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
}

- (void)vungleAdWillLeaveApplication
{
    MPLogAdEvent([MPLogEvent adWillLeaveApplicationForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
}

- (void)vungleAdDidFailToLoad:(NSError *)error
{
    if (self.isAdLoaded) {
        return;
    }
    
    NSString *errorMsg = [NSString stringWithFormat:@"%@, %@", ADX_EVENT_LOAD_FAILURE, error.description];
    ADXLogEvent(ADX_PLATFORM_VUNGLE, ADX_INVENTORY_INTERSTITIAL, errorMsg);
    
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getPlacementID]);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
    [self cleanUp];
}

- (void)vungleAdDidFailToPlay:(NSError *)error
{
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getPlacementID]);
    [self.delegate fullscreenAdAdapter:self didFailToShowAdWithError:error];
    [self cleanUp];
}

- (NSString *)getPlacementID
{
    return self.placementId;
}

@end