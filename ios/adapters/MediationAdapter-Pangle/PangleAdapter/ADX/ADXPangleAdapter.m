//
//  ADXPangleAdapter.m
//  ADXLibrary-Pangle
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "ADXPangleAdapter.h"

#import <ADXLibrary/ADXGdprManager.h>

NSString *const ADXPangleErrorDomain = @"com.adx.sdk.mediation.pangle";
static NSString *const ADXPangleAppIdKey = @"app_id";

@interface ADXPangleAdapter ()
@property (assign) BOOL isInitialized;
@end

@implementation ADXPangleAdapter

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
        [sharedInstance setIsInitialized:NO];
    });
    return sharedInstance;
}

+ (NSString *)adapterVersion {
    return [NSString stringWithFormat:@"%@.0", PAGSdk.SDKVersion];
}

+ (nonnull NSString *)networkSdkVersion {
    return PAGSdk.SDKVersion;
}

+ (void)initializeSdkWithConfiguration:(nullable NSDictionary *)configuration
                     completionHandler:(nullable ADXMediationAdapterCompletionHandler)completionHandler
{
    PAGSDKInitializationState state = PAGSdk.initializationState;
    BOOL isInitialized = [[ADXPangleAdapter sharedInstance] isInitialized];
    ADXLogInfo(@"PAGSDKInitializationState: %d, isInitialized: %d", state, isInitialized);
    if (state == PAGSDKInitializationStateReady && isInitialized) {
        ADXLogInfo(@"PAGSDKInitializationStateReady");
        completionHandler == nil ? : completionHandler(YES, nil);
        return;
    }
    
    NSString * appId = [configuration objectForKey:ADXPangleAppIdKey];
    if (![appId length]) {
        NSError * error = [NSError errorWithDomain:ADXPangleErrorDomain
                                             code:ADXAdErrorSdkNotInitialize
                                      description:@"AppId is empty"];
        completionHandler == nil ? : completionHandler(NO, error);
        return;
    }
    
    PAGConfig * config = [PAGConfig shareConfig];
    config.appID = appId;
    config.PAConsent = PAGPAConsentTypeNoConsent;
    config.debugLog = NO;
    
    /// PAConsent
    ADXConsentState consentState = [ADXGdprManager sharedInstance].consentState;
    if (consentState == ADXConsentStateConfirm) {
        config.PAConsent = PAGPAConsentTypeConsent;
    } else if (consentState == ADXConsentStateDenied) {
        config.PAConsent = PAGPAConsentTypeNoConsent;
    }
    
    /// debugLog
    if ([ADXLog sharedInstance].logLevel == ADXLogLevelVerbose) {
        config.debugLog = YES;
    }
    
    /// Starts the Pangle SDK
    [PAGSdk startWithConfig:config completionHandler:^(BOOL success, NSError * _Nonnull error) {
        if (success) {
            ADXLogInfo(@"Pangle SDK (v%@) initialized successfully.", ADXPangleAdapter.networkSdkVersion);
            ADXLogDebug(@"Pangle App ID: %@", appId);
            [[ADXPangleAdapter sharedInstance] setIsInitialized:success];
        }
        completionHandler == nil ? : completionHandler(success, error);
    }];
}

@end
