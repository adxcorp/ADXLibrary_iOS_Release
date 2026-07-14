//
//  AdMobAdPieRewardedAd.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "AdMobAdPieRewardedAd.h"

#import <AdPieSDK/AdPieSDK.h>
#include <stdatomic.h>

#import <ADXLibrary/ADXAdLogEvent.h>
#import <ADXLibrary/ADXAdError.h>
#import "ADXAdPieAdapter.h"

@interface AdMobAdPieRewardedAd () <GADMediationRewardedAd, APRewardedAdDelegate> {
    GADMediationRewardedLoadCompletionHandler _adLoadCompletionHandler;
    __weak id<GADMediationRewardedAdEventDelegate> _delegate;
}

@property (strong) APRewardedAd *rewardedAd;

@end

@implementation AdMobAdPieRewardedAd

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    
    if(err == nil && [result isKindOfClass:[NSDictionary class]]) {
        return result;
    }
    
    return nil;
}

#pragma mark - GADMediationAdapter

+ (GADVersionNumber)adSDKVersion {
    NSString *versionString = [AdPieSDK sdkVersion];
    NSArray *versionComponents = [versionString componentsSeparatedByString:@"."];
    
    GADVersionNumber version = {0};
    if (versionComponents.count >= 3) {
        version.majorVersion = [versionComponents[0] integerValue];
        version.minorVersion = [versionComponents[1] integerValue];
        version.patchVersion = [versionComponents[2] integerValue];
    }
    return version;
}

+ (GADVersionNumber)adapterVersion {
    NSString *versionString = [NSString stringWithFormat:@"%@.0", [AdPieSDK sdkVersion]];
    NSArray *versionComponents = [versionString componentsSeparatedByString:@"."];
    GADVersionNumber version = {0};
    if (versionComponents.count >= 4) {
        version.majorVersion = [versionComponents[0] integerValue];
        version.minorVersion = [versionComponents[1] integerValue];
        version.patchVersion = [versionComponents[2] integerValue] * 100 + [versionComponents[3] integerValue];
    }
    return version;
}

+ (nullable Class<GADAdNetworkExtras>)networkExtrasClass {
    return nil;
}

+ (void)setUpWithConfiguration:(GADMediationServerConfiguration *)configuration completionHandler:(GADMediationAdapterSetUpCompletionBlock)completionHandler {
    if ([[AdPieSDK sharedInstance] isInitialized]) {
        completionHandler(nil);
        return;
    }
    
    NSString *parameter = configuration.credentials.firstObject.settings[@"parameter"];
    NSDictionary *info = [AdMobAdPieRewardedAd dictionaryWithJsonString:parameter];
    NSString *appId = [info objectForKey:@"app_id"];
    
    if (appId == nil || appId.length == 0) {
        NSError *error = [NSError errorWithCode:ADXAdErrorSdkNotInitialize description:@"AdPie initialization failed. The app id is empty."];
        completionHandler(error);
        return;
    }
    
    [ADXAdPieAdapter initializeAdPieSdk:appId completion:^(BOOL initialized, NSError *error) {
        if (initialized) {
            completionHandler(nil);
        } else {
            NSError *error = [NSError errorWithCode:ADXAdErrorSdkNotInitialize description:@"AdPie SDK must be initialized before ads loading."];
            completionHandler(error);
        }
    }];
}

- (void)loadRewardedAdForAdConfiguration:(GADMediationRewardedAdConfiguration *)adConfiguration completionHandler:(GADMediationRewardedLoadCompletionHandler)completionHandler {
    // Store the completion handler for later use.
    __block atomic_flag completionHandlerCalled = ATOMIC_FLAG_INIT;
    __block GADMediationRewardedLoadCompletionHandler originalCompletionHandler = [completionHandler copy];
    _adLoadCompletionHandler = ^id<GADMediationRewardedAdEventDelegate>(_Nullable id<GADMediationRewardedAd> ad, NSError *_Nullable error) {
        if (atomic_flag_test_and_set(&completionHandlerCalled)) {
            return nil;
        }
        id<GADMediationRewardedAdEventDelegate> delegate = nil;
        if (originalCompletionHandler) {
            delegate = originalCompletionHandler(ad, error);
        }
        originalCompletionHandler = nil;
        return delegate;
    };
    
    NSString *parameter = adConfiguration.credentials.settings[@"parameter"];
    NSDictionary *info = [AdMobAdPieRewardedAd dictionaryWithJsonString:parameter];
    NSString *slotId = [info objectForKey:@"slot_id"];
    
    if (slotId == nil || slotId.length == 0) {
        NSError *error = [NSError errorWithCode:ADXAdErrorInvalidRequest description:@"AdPie SDK slot ID cannot be nil."];
        ADXDebugLogError(@"%@", error.description);
        _adLoadCompletionHandler(nil, error);
        
        return;
    }
    
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeRewarded, ADXAdEventLoad);
    ADXLogDebug(@"Rewarded ad load - %@", slotId);
    
    self.rewardedAd = [[APRewardedAd alloc] initWithSlotId:slotId];
    self.rewardedAd.delegate = self;
    
    NSString *floorPrice = [info objectForKey:@"floor_price"];
    if (floorPrice != nil) {
        [self.rewardedAd setExtraParameterForKey:@"floorPrice" value:floorPrice];
    }
    
    [self.rewardedAd load];
}

- (void)presentFromViewController:(UIViewController *)viewController {
    [self.rewardedAd presentFromRootViewController:viewController];
}


#pragma mark - APRewardedAdDelegate

- (void)rewardedAdDidLoadAd:(APRewardedAd *)rewardedAd {
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeRewarded, ADXAdEventLoaded);
    ADXLogDebug(@"Rewarded ad loaded: %@", rewardedAd.slotId);
    
    _delegate = _adLoadCompletionHandler(self, nil);
}

- (void)rewardedAdDidFailToLoadAd:(APRewardedAd *)rewardedAd withError:(NSError *)error {
    ADXLogEventError(ADXAdNetworkAdPie, ADXAdTypeRewarded, ADXAdEventLoadFailed, error);
    ADXLogError(@"Rewarded ad (%@) failed to load with error: %@", rewardedAd.slotId, error);
    
    _adLoadCompletionHandler(nil, [NSError errorWithCode:ADXAdErrorNoFill]);
}

- (void)rewardedAdWillPresentScreen:(APRewardedAd *)rewardedAd {
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeRewarded, ADXAdEventShown);
    ADXLogDebug(@"Rewarded ad shown: %@", rewardedAd.slotId);
    
    id<GADMediationRewardedAdEventDelegate> strongDelegate = _delegate;
    [strongDelegate willPresentFullScreenView];
    [strongDelegate reportImpression];
}

- (void)rewardedAdDidDismissScreen:(APRewardedAd *)rewardedAd {
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeRewarded, ADXAdEventClose);
    ADXLogDebug(@"Rewarded ad close: %@", rewardedAd.slotId);
    
    id<GADMediationRewardedAdEventDelegate> strongDelegate = _delegate;
    [strongDelegate didDismissFullScreenView];
}

- (void)rewardedAdWillLeaveApplication:(APRewardedAd *)rewardedAd {
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeRewarded, ADXAdEventClick);
    ADXLogDebug(@"Rewarded ad clicked: %@", rewardedAd.slotId);
    
    id<GADMediationRewardedAdEventDelegate> strongDelegate = _delegate;
    [strongDelegate reportClick];
}

- (void)rewardedAdDidEarnReward:(APRewardedAd *)rewardedAd {
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeRewarded, ADXAdEventReward);
    ADXLogDebug(@"Rewarded ad user with reward: %@", rewardedAd.slotId);
    
    //GADAdReward *reward = [[GADAdReward alloc] initWithRewardType:@"" rewardAmount:[NSDecimalNumber one]];
    
    id<GADMediationRewardedAdEventDelegate> strongDelegate = _delegate;
    //[strongDelegate didRewardUserWithReward:reward];
    [strongDelegate didRewardUser];
}

@end
