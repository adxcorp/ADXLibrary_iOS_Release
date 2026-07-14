//
//  ADXFyberAdapter.m
//  ADXLibrary-Fyber
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "ADXFyberAdapter.h"

#import <ADXLibrary/ADXGdprManager.h>

NSString *const ADXFyberErrorDomain = @"com.adx.sdk.mediation.fyber";
static NSString *const ADXFyberAppIdKey = @"app_id";

@implementation ADXFyberAdapter

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    
    return sharedInstance;
}

+ (NSString *)adapterVersion {
    return @"8.4.5.0";
}

+ (NSString *)networkSdkVersion {
    return IASDKCore.sharedInstance.version;
}

+ (void)initializeSdkWithConfiguration:(NSDictionary *)configuration completionHandler:(ADXMediationAdapterCompletionHandler)completionHandler {
    if (IASDKCore.sharedInstance.isInitialised) {
        if (completionHandler) {
            completionHandler(YES, nil);
        }
        return;
    }
    
    NSString *appId = [configuration objectForKey:ADXFyberAppIdKey];
    if (appId == nil || appId.length == 0) {
        if (completionHandler) {
            NSError *error = [NSError errorWithDomain:ADXFyberErrorDomain
                                                 code:ADXAdErrorSdkNotInitialize
                                          description:@"Fyber initialization failed. The appId is empty."];
            completionHandler(NO, error);
        }
        return;
    }
    
    [[ADXFyberAdapter sharedInstance] setGDPRConsentState];
    
    if ([ADXLog sharedInstance].logLevel == ADXLogLevelVerbose) {
        [DTXLogger setLogLevel:DTXLogLevelDebug];
    } else {
        [DTXLogger setLogLevel:DTXLogLevelError];
    }
    
    [IASDKCore.sharedInstance initWithAppID:appId completionBlock:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            ADXLogInfo(@"Fyber SDK (v%@) initialized successfully.", ADXFyberAdapter.networkSdkVersion);
            ADXLogDebug(@"Fyber App ID: %@", appId);
        }
        
        if (completionHandler) {
            completionHandler(success, error);
        }
        
    } completionQueue:nil];
}

- (void)setGDPRConsentState {
    ADXConsentState consentState = [ADXGdprManager sharedInstance].consentState;
    // GDPR 대상일때만 설정
    if (consentState == ADXConsentStateConfirm) {
        IASDKCore.sharedInstance.GDPRConsent = IAGDPRConsentTypeGiven;
        
    } else if (consentState == ADXConsentStateDenied) {
        IASDKCore.sharedInstance.GDPRConsent = IAGDPRConsentTypeDenied;
    }
}

@end
