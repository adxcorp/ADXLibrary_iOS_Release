//
//  ADXAdMobAdapter.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "ADXAdMobAdapter.h"
#import <ADXLibrary/ADXConfiguration.h>
#import <ADXLibrary/ADXGdprManager.h>

NSString *const ADXAdMobErrorDomain = @"com.adx.sdk.mediation.admob";
NSString *const ADXAdManagerErrorDomain = @"com.adx.sdk.mediation.admanager";

static NSString *const ADXAdMobAppIdKey = @"GADApplicationIdentifier";

@implementation ADXAdMobAdapter

+ (NSString *)adapterVersion {
    return [NSString stringWithFormat:@"%@.0",[ADXAdMobAdapter networkSdkVersion]];
}

+ (NSString *)networkSdkVersion {
    return GADGetStringFromVersionNumber([GADMobileAds sharedInstance].versionNumber);
}

+ (void)initializeSdkWithConfiguration:(nullable NSDictionary *)configuration {
    NSString *admobAppId = [ADXConfiguration.mainAppBundle objectForInfoDictionaryKey:ADXAdMobAppIdKey];
    
    if ([GADMobileAds sharedInstance].initializationStatus != nil) {
      ADXLogInfo(@"AdMob SDK (v%@) already initialized by another. AdMob App Id: %@",
                 ADXAdMobAdapter.networkSdkVersion, admobAppId);
      return;
    }
    
    if (admobAppId != nil && admobAppId.length > 0) {
        [GADMobileAds.sharedInstance setApplicationMuted:YES];
        [GADMobileAds.sharedInstance.audioVideoManager setAudioSessionIsApplicationManaged:YES];
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *status) {
                    ADXLogInfo(@"AdMob SDK (v%@) initialized successfully. AdMob App Id: %@", ADXAdMobAdapter.networkSdkVersion, admobAppId);
                    ADXLogDebug(@"AdMob App ID: %@", admobAppId);
                }];
            });
        });
    }
}

+ (GADRequest *)gdprGADRequest {
    GADRequest *request = [GADRequest request];
    
    if ([ADXGdprManager sharedInstance].consentState == ADXConsentStateDenied) {
        // 사용자가 개인정보 활용 및 수집을 거부한 상태일때 npa = 1 세팅
        GADExtras *extras = [[GADExtras alloc] init];
        extras.additionalParameters = @{@"npa": @"1"};
        [request registerAdNetworkExtras:extras];
    }
    
    return request;
}

+ (GAMRequest *)gdprGAMRequest {
    GAMRequest *request = [GAMRequest request];
    
    if ([ADXGdprManager sharedInstance].consentState == ADXConsentStateDenied) {
        // 사용자가 개인정보 활용 및 수집을 거부한 상태일때 npa = 1 세팅
        GADExtras *extras = [[GADExtras alloc] init];
        extras.additionalParameters = @{@"npa": @"1"};
        [request registerAdNetworkExtras:extras];
    }
    
    return request;
}

+ (void)printAdNetworkResponseInfo:(GADResponseInfo *)info {
    GADResponseInfo * responseInfo = info;
    if (!responseInfo) { return; }
    GADAdNetworkResponseInfo * loadedInfo = [responseInfo loadedAdNetworkResponseInfo];
    if (!loadedInfo) { return; }
    NSString *networkName = loadedInfo.adSourceName;
    NSString *adapterClassName = loadedInfo.adNetworkClassName;
    NSString *adSourceInstanceName = loadedInfo.adSourceInstanceName;
    NSDictionary<NSString *, id> *adUnitMapping = loadedInfo.adUnitMapping;
    ADXLogDebug(@"[AdNetworkResponseInfo] networkName: %@, adapterClassName: %@, adSourceInstanceName: %@, %@",
                networkName, adapterClassName, adSourceInstanceName, adUnitMapping);
}

@end
