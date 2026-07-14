//
//  AdMobAdPieInterstitialAd.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "AdMobAdPieInterstitialAd.h"

#import <AdPieSDK/AdPieSDK.h>
#include <stdatomic.h>

#import <ADXLibrary/ADXAdLogEvent.h>
#import <ADXLibrary/ADXAdError.h>
#import "ADXAdPieAdapter.h"

@interface AdMobAdPieInterstitialAd () <GADMediationInterstitialAd, APInterstitialDelegate> {
    GADMediationInterstitialLoadCompletionHandler _adLoadCompletionHandler;
    __weak id<GADMediationInterstitialAdEventDelegate> _delegate;
}

@property (strong) APInterstitial *interstitialAd;

@end

@implementation AdMobAdPieInterstitialAd

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
    NSDictionary *info = [AdMobAdPieInterstitialAd dictionaryWithJsonString:parameter];
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

- (void)loadInterstitialForAdConfiguration:(GADMediationInterstitialAdConfiguration *)adConfiguration completionHandler:(GADMediationInterstitialLoadCompletionHandler)completionHandler {
    // Store the completion handler for later use.
    __block atomic_flag completionHandlerCalled = ATOMIC_FLAG_INIT;
    __block GADMediationInterstitialLoadCompletionHandler originalCompletionHandler = [completionHandler copy];
    _adLoadCompletionHandler = ^id<GADMediationInterstitialAdEventDelegate>(_Nullable id<GADMediationInterstitialAd> ad, NSError *_Nullable error) {
        if (atomic_flag_test_and_set(&completionHandlerCalled)) {
            return nil;
        }
        id<GADMediationInterstitialAdEventDelegate> delegate = nil;
        if (originalCompletionHandler) {
            delegate = originalCompletionHandler(ad, error);
        }
        originalCompletionHandler = nil;
        return delegate;
    };
    
    // load
    NSString *parameter = adConfiguration.credentials.settings[@"parameter"];
    NSDictionary *info = [AdMobAdPieInterstitialAd dictionaryWithJsonString:parameter];
    NSString *slotId = [info objectForKey:@"slot_id"];
    
    if (slotId == nil || slotId.length == 0) {
        NSError *error = [NSError errorWithCode:ADXAdErrorInvalidRequest description:@"AdPie SDK slot ID cannot be nil."];
        ADXDebugLogError(@"%@", error.description);
        _adLoadCompletionHandler(nil, error);
        
        return;
    }
    
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeInterstitial, ADXAdEventLoad);
    ADXLogDebug(@"Interstitial ad load - %@", slotId);
    
    self.interstitialAd = [[APInterstitial alloc] initWithSlotId:slotId];
    self.interstitialAd.delegate = self;
    
    NSString *floorPrice = [info objectForKey:@"floor_price"];
    if (floorPrice != nil) {
        [self.interstitialAd setExtraParameterForKey:@"floorPrice" value:floorPrice];
    }
    [self.interstitialAd load];
}

- (void)presentFromViewController:(UIViewController *)viewController {
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeInterstitial, ADXAdEventShow);
    
    if (self.interstitialAd.isReady) {
        [self.interstitialAd presentFromRootViewController:viewController];
    }
}


#pragma mark - APInterstitialDelegate

- (void)interstitialDidLoadAd:(APInterstitial *)interstitial {
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeInterstitial, ADXAdEventLoaded);
    ADXDebugLog(@"Interstitial ad loaded: %@", interstitial.slotId);
    
    _delegate = _adLoadCompletionHandler(self, nil);
}

- (void)interstitialDidFailToLoadAd:(APInterstitial *)interstitial withError:(NSError *)error {
    ADXLogEventError(ADXAdNetworkAdPie, ADXAdTypeInterstitial, ADXAdEventLoadFailed, error);
    ADXLogError(@"Interstitial ad (%@) failed to load with error: %@", interstitial.slotId, error);
    
    _adLoadCompletionHandler(nil, [NSError errorWithCode:ADXAdErrorNoFill]);
}

- (void)interstitialWillPresentScreen:(APInterstitial *)interstitial {
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeInterstitial, ADXAdEventShown);
    ADXLogDebug(@"Interstitial ad shown: %@", interstitial.slotId);
    
    id<GADMediationInterstitialAdEventDelegate> strongDelegate = _delegate;
    [strongDelegate willPresentFullScreenView];
    [strongDelegate reportImpression];
}

- (void)interstitialWillDismissScreen:(APInterstitial *)interstitial {
    id<GADMediationInterstitialAdEventDelegate> strongDelegate = _delegate;
    [strongDelegate willDismissFullScreenView];
}

- (void)interstitialDidDismissScreen:(APInterstitial *)interstitial {
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeInterstitial, ADXAdEventClose);
    ADXLogDebug(@"Interstitial ad close: %@", interstitial.slotId);
    
    id<GADMediationInterstitialAdEventDelegate> strongDelegate = _delegate;
    [strongDelegate didDismissFullScreenView];
}

- (void)interstitialWillLeaveApplication:(APInterstitial *)interstitial {
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeInterstitial, ADXAdEventClick);
    ADXLogDebug(@"Interstitial ad clicked: %@", interstitial.slotId);
    
    id<GADMediationInterstitialAdEventDelegate> strongDelegate = _delegate;
    [strongDelegate reportClick];
}

@end
