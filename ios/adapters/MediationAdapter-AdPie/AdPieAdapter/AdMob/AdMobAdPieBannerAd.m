//
//  AdMobAdPieBannerAd.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "AdMobAdPieBannerAd.h"

#import <AdPieSDK/AdPieSDK.h>
#include <stdatomic.h>

#import <ADXLibrary/ADXAdLogEvent.h>
#import <ADXLibrary/ADXAdError.h>
#import "ADXAdPieAdapter.h"

@interface AdMobAdPieBannerAd () <GADMediationBannerAd, APAdViewDelegate> {
    GADMediationBannerLoadCompletionHandler _adLoadCompletionHandler;
    __weak id<GADMediationBannerAdEventDelegate> _delegate;
}

@property (strong) APAdView *adView;

@end

@implementation AdMobAdPieBannerAd

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
    NSDictionary *info = [AdMobAdPieBannerAd dictionaryWithJsonString:parameter];
    NSString *appId = [info objectForKey:@"app_id"];
    
    if (appId == nil || appId.length == 0) {
        NSError *error = [NSError errorWithCode:ADXAdErrorSdkNotInitialize description:@"AdPie SDK initialization failed. The app id is empty."];
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

- (void)loadBannerForAdConfiguration:(GADMediationBannerAdConfiguration *)adConfiguration completionHandler:(GADMediationBannerLoadCompletionHandler)completionHandler {
    __block atomic_flag completionHandlerCalled = ATOMIC_FLAG_INIT;
    __block GADMediationBannerLoadCompletionHandler originalCompletionHandler = [completionHandler copy];
    _adLoadCompletionHandler = ^id<GADMediationBannerAdEventDelegate>(_Nullable id<GADMediationBannerAd> ad, NSError *_Nullable error) {
        if (atomic_flag_test_and_set(&completionHandlerCalled)) {
            return nil;
        }
        id<GADMediationBannerAdEventDelegate> delegate = nil;
        if (originalCompletionHandler) {
            delegate = originalCompletionHandler(ad, error);
        }
        originalCompletionHandler = nil;
        return delegate;
    };
    
    // load
    NSString *parameter = adConfiguration.credentials.settings[@"parameter"];
    NSDictionary *info = [AdMobAdPieBannerAd dictionaryWithJsonString:parameter];
    NSString *slotId = [info objectForKey:@"slot_id"];
    
    if (slotId == nil || slotId.length == 0) {
        NSError *error = [NSError errorWithCode:ADXAdErrorInvalidRequest description:@"AdPie SDK slot ID cannot be nil."];
        ADXDebugLogError(@"%@", error.description);
        _adLoadCompletionHandler(nil, error);
        
        return;
    }
    
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeBanner, ADXAdEventLoad);
    ADXLogDebug(@"Banner ad load - %@", slotId);
    
    UIViewController *rootViewController = adConfiguration.topViewController;
    if (!rootViewController) {
        NSError *error = [NSError errorWithCode:ADXAdErrorInvalidRequest description:@"Root view controller cannot be nil."];
        
        _adLoadCompletionHandler(nil, error);
        return;
    }
    
    CGSize bannerSize = adConfiguration.adSize.size;
    
    self.adView = [[APAdView alloc] initWithFrame:CGRectMake(0, 0, bannerSize.width, bannerSize.height)];
    self.adView.slotId = slotId;
    self.adView.delegate = self;
    self.adView.rootViewController = rootViewController;
    
    NSString *floorPrice = [info objectForKey:@"floor_price"];
    if (floorPrice != nil) {
        [self.adView setExtraParameterForKey:@"floorPrice" value:floorPrice];
    }
    
    [self.adView load];
}


#pragma mark - APAdViewDelegate

- (void)adViewDidLoadAd:(APAdView *)view {
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeBanner, ADXAdEventLoaded);
    ADXDebugLog(@"Banner ad loaded: %@", view.slotId);
    
    _delegate = _adLoadCompletionHandler(self, nil);
}

- (void)adViewDidFailToLoadAd:(APAdView *)view withError:(NSError *)error {
    ADXLogEventError(ADXAdNetworkAdPie, ADXAdTypeBanner, ADXAdEventLoadFailed, error);
    ADXDebugLogError(@"Banner ad (%@) failed to load with error: %@", view.slotId, error);
    
    _adLoadCompletionHandler(nil, [NSError errorWithCode:ADXAdErrorNoFill]);
}

- (void)adViewWillLeaveApplication:(APAdView *)view {
    ADXLogEvent(ADXAdNetworkAdPie, ADXAdTypeBanner, ADXAdEventClick);
    ADXDebugLog(@"Banner ad clicked: %@", view.slotId);
    
    id<GADMediationBannerAdEventDelegate> strongDelegate = _delegate;
    [strongDelegate reportClick];
}


#pragma mark - GADMediationBannerAd

- (UIView *)view {
    return _adView;
}

@end
