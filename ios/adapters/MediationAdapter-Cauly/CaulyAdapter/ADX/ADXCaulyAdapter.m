//
//  ADXCaulyAdapter.m
//  ADXLibrary-Cauly
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "ADXCaulyAdapter.h"

NSString *const ADXCaulyErrorDomain = @"com.adx.sdk.mediation.cauly";
static NSString *const ADXCaulyAppIdKey = @"app_id";
static NSString *const ADXCaulyAppCodeKey = @"app_code";

@implementation ADXCaulyAdapter

+ (NSString *)adapterVersion {
    NSString *versionString = [NSString stringWithFormat:@"%@.0", CAULY_SDK_VERSION];
    return versionString;
}

+ (NSString *)networkSdkVersion {
    return CAULY_SDK_VERSION;
}

+ (void)initializeSdkWithConfiguration:(nullable NSDictionary *)configuration completionHandler:(ADXMediationAdapterCompletionHandler)completionHandler {
    NSString *appId = [configuration objectForKey:ADXCaulyAppIdKey]; // App Store에 등록된 App ID 정보 (필수)
    NSString *appCode = [configuration objectForKey:ADXCaulyAppCodeKey];
    
    if (appId == nil || appId.length == 0) {
        if (completionHandler) {
            NSError *error = [NSError errorWithDomain:ADXCaulyErrorDomain code:ADXAdErrorSdkNotInitialize description:@"Cauly initialization failed. The appId is empty."];
            completionHandler(NO, error);
        }
        return;
    }
    
    if (appCode == nil || appCode.length == 0) {
        if (completionHandler) {
            NSError *error = [NSError errorWithDomain:ADXCaulyErrorDomain code:ADXAdErrorSdkNotInitialize description:@"Cauly initialization failed. The appCode is empty."];
            completionHandler(NO, error);
        }
        return;
    }
    
    CaulyAdSetting *adSetting = [CaulyAdSetting globalSetting];
    adSetting.appId = appId;
    adSetting.appCode = appCode;
    
    if ([ADXLog sharedInstance].logLevel == ADXLogLevelVerbose) {
        [CaulyAdSetting setLogLevel:CaulyLogLevelTrace];
        
    } else {
        [CaulyAdSetting setLogLevel:CaulyLogLevelError];
    }
    
    ADXLogInfo(@"Cauly SDK (v%@)", ADXCaulyAdapter.networkSdkVersion);
    ADXLogDebug(@"Cauly AdSetting: appId = %@, appCode = %@", appId, appCode);
    
    if (completionHandler) {
        completionHandler(YES, nil);
    }
}

@end
