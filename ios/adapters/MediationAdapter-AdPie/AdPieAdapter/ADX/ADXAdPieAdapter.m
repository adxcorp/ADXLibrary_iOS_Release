//
//  ADXAdPieAdapter.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "ADXAdPieAdapter.h"
#import <ADXLibrary/ADXAdLoader.h>

NSString *const ADXAdPieErrorDomain = @"com.adx.sdk.mediation.adpie";
static NSString *const ADXAdPieMediationIdKey = @"mid";

@implementation ADXAdPieAdapter

+ (NSString *)adapterVersion {
    return [NSString stringWithFormat:@"%@.0",AdPieSDK.sdkVersion];
}

+ (NSString *)networkSdkVersion {
    return AdPieSDK.sdkVersion;
}

+ (void)initializeSdkWithConfiguration:(NSDictionary *)configuration
                     completionHandler:(ADXMediationAdapterCompletionHandler)completionHandler {
    
    NSString *mediationId = [configuration objectForKey:ADXAdPieMediationIdKey];
    if (mediationId == nil || mediationId.length == 0) {
        NSError *error = [NSError errorWithDomain:ADXAdPieErrorDomain
                                             code:ADXAdErrorSdkNotInitialize
                                      description:@"AdPie initialization failed. The media id is empty."];
        [ADXAdPieAdapter finishCompletionHandler:NO
                                           error:error
                               completionHandler:completionHandler];
        return;
    }
    
    if ([[AdPieSDK sharedInstance] isInitialized]) {
        ADXLogInfo(@"AdPie SDK is initialized already");
        [ADXAdPieAdapter finishCompletionHandler:YES
                                           error:nil
                               completionHandler:completionHandler];
        return;
    }
    
    [ADXAdPieAdapter initializeAdPieSdk:mediationId completion:^(BOOL initialized, NSError *error) {
        [ADXAdPieAdapter finishCompletionHandler:initialized
                                           error:error
                               completionHandler:completionHandler];
    }];
}

+ (void)initializeAdPieSdk:(NSString *)mediaID
                completion:(void(^)(BOOL initialized, NSError * error))completion
{
    [[AdPieSDK sharedInstance] initWithMediaId:mediaID
                                      withData:[ADXAdPieAdapter makeAdPieConfigData]
                                    completion:^(BOOL isInitialized)
     {
        NSError * error = nil;
        if (isInitialized) {
            ADXLogInfo(@"AdPie SDK (v%@) initialized successfully.", AdPieSDK.sdkVersion);
            ADXLogDebug(@"AdPie media ID: %@", mediaID);
        } else {
            ADXLogInfo(@"failed to initialize AdPie SDK");
            error = [NSError errorWithDomain:ADXAdPieErrorDomain
                                        code:ADXAdErrorSdkNotInitialize
                                 description:@"AdPie SDK must be initialized before ads loading."];
        }
        if([ADXLog sharedInstance].debuggable) {
            [[AdPieSDK sharedInstance] logging];
        }
        if(!completion) { return; }
        dispatch_async(dispatch_get_main_queue(), ^{ completion(isInitialized, error); });
    }];
}


+ (void)finishCompletionHandler:(BOOL)result
                        error:(NSError *)error
            completionHandler:(nullable ADXMediationAdapterCompletionHandler)completionHandler {
    if (!completionHandler) { return; }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (result) {
            completionHandler(result, nil);
        }else{
            completionHandler(result, error);
        }
    });
}

+ (NSData *)makeAdPieConfigData {
    NSString * requestURL = [ADXAdLoader getTargetDomainForLite:@"ssp.adpies.com/ssp/request"
                                                stringToReplace:@"ssp.adpies.com/ssp/request"
                                                     liteDomain:@"liteAdPieDomain"
                                                  defaultDomain:@""];
    
    NSString * configURL = [ADXAdLoader getTargetDomainForLite:@"adp.adpies.com/adp/config"
                                               stringToReplace:@"adp.adpies.com/adp/config"
                                                    liteDomain:@"liteAdPieConfigDomain"
                                                 defaultDomain:@""];
    
    NSDictionary * configDict = @{
        @"adpie_config_url": configURL,
        @"adpie_ssp_url": requestURL
    };
    
    ADXLogDebug(@"AdPie ConfigDict: %@", configDict);
    return [NSJSONSerialization dataWithJSONObject:configDict options:0 error:nil];
}

@end
