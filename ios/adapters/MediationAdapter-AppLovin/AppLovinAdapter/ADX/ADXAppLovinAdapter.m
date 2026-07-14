//
//  ADXAppLovinAdapter.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "ADXAppLovinAdapter.h"

#import <ADXLibrary/ADXGdprManager.h>

NSString *const ADXAppLovinErrorDomain = @"com.adx.sdk.mediation.applovin";
NSString *const ADXAppLovinBiddingKitKey = @"jC7Fp";
NSString *const ADXAppLovinSdkKey = @"all5Np4vhK18b2M9MU60lgkHJJU3oB0NxmSIZXCGsDPSFnbcGic_OKGhemmQxnotXE95mLMcZm4pXfPoN1nmM1";

@implementation ADXAppLovinAdapter

+ (NSString *)adapterVersion {
    return @"13.5.1.0";
}

+ (NSString *)networkSdkVersion {
    return ALSdk.version;
}

+ (void)initializeSdkWithConfiguration:(NSDictionary *)configuration 
                     completionHandler:(ADXMediationAdapterCompletionHandler)completionHandler
{
    ALSdk *sdk = [ADXAppLovinAdapter appLovinSdk];
    if (sdk.initialized) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler == nil ? : completionHandler(YES, nil);
        });
        return;
    }
    
    ALSdkInitializationConfiguration * initConfig = [ALSdkInitializationConfiguration configurationWithSdkKey:ADXAppLovinSdkKey builderBlock:^(ALSdkInitializationConfigurationBuilder *builder) {
        builder.mediationProvider = ALMediationProviderMAX;
    }];
    
    [sdk initializeWithConfiguration:initConfig completionHandler:^(ALSdkConfiguration *configuration) {
        if (sdk.initialized) {
            [ADXAppLovinAdapter setGDPRConsentState];
            ADXLogInfo(@"AppLovin SDK (v%@) initialized successfully.", ADXAppLovinAdapter.networkSdkVersion);
            ADXLogDebug(@"AppLovin initialize SDK Key: %@", ADXAppLovinSdkKey);
            if (completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    ADXLogDebug(@"call completion handler");
                    completionHandler == nil ? : completionHandler(YES, nil);
                });
            }
            return;
        }
        
        NSError *error = [NSError errorWithDomain:ADXAppLovinErrorDomain
                                             code:ADXAdErrorSdkNotInitialize
                                      description:@"AppLovin initialization failed."];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            ADXLogDebug(@"call completion handler with an error");
            completionHandler == nil ? : completionHandler(NO, error);
        });
    }];
}

+ (NSString *)getAppLovinAdUnitIDs:(NSString *)adUnitID {
    @try {
        NSString *key = @"adx_disable_b2b_ad_unit_ids";
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *adUnitMutableArray = [NSMutableArray array];
        
        // 기존에 저장된 AdUnitID 목록을 'NSUserDefaults'에서 가져오기
        NSArray *adUnitArray = [userDefaults arrayForKey:key];
        if([adUnitArray count] != 0) {
            adUnitMutableArray = [NSMutableArray arrayWithArray:adUnitArray];
        }
        // 현재 AdUnitID 갯수 저장
        NSInteger arrayCount = [adUnitMutableArray count];
        // 추가할 AdUnitID가 빈 문자열이 아니라면
        if([adUnitID length]) {
            // 파라메터로 받은 AdUnitID 추가 (중복 제거는 아래 코드에서 수행되니, 무시하고 일단 추가)
            [adUnitMutableArray addObject:adUnitID];
            // 중복제거
            NSOrderedSet *orderSet = [[NSOrderedSet alloc] initWithArray:adUnitMutableArray];
            adUnitMutableArray = [[NSMutableArray alloc] initWithArray:[orderSet array]];
            // 갯수가 다르다는 것은 추가가 되었다는 의미이므로, 갱신된 값 새로 저장
            if(arrayCount != [adUnitMutableArray count]){
                [userDefaults setObject:[adUnitMutableArray copy] forKey:key];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        // "," 문자로 각 AdUnitID를 연결하여 리턴 (배열에 1개만 있을 경우 ',' 문자없이 그대로 리턴 됨)
        NSString *joinedString = [adUnitMutableArray componentsJoinedByString:@","];
        return [joinedString length] != 0 ? joinedString : adUnitID;
    } @catch (NSException *exception) {
        return adUnitID;
    }
}

+ (ALSdk *)appLovinSdk {
    ALSdk * sdk = [ALSdk shared];
    sdk.settings.muted = YES;
    sdk.settings.creativeDebuggerEnabled = NO;
    [sdk.settings setExtraParameterForKey:@"return_audio_focus" value:@"true"];
    
    if ([ADXLog sharedInstance].logLevel == ADXLogLevelVerbose) {
        sdk.settings.verboseLoggingEnabled = YES;
    } else {
        sdk.settings.verboseLoggingEnabled = NO;
    }
    
    return sdk;
}

+ (void)setGDPRConsentState {
    ADXConsentState consentState = [ADXGdprManager sharedInstance].consentState;
    
    if (consentState == ADXConsentStateDenied) {
        [ALPrivacySettings setHasUserConsent:NO];
        
    } else {
        [ALPrivacySettings setHasUserConsent:YES];
    }
}

+ (void)printAdNetworkResponseInfo:(MAAd *)ad {
    NSString *networkName   = [ad networkName];
    NSString *adUnitId      = [ad adUnitIdentifier];
    NSString *placement     = [ad placement];
    double    revenue       = [ad revenue];
    NSString *revenuePrecision = [ad revenuePrecision];
    NSString *dspName       = [ad DSPName];
    NSString *format        = [ad.format label];
    ADXLogDebug(@"[printAdNetworkResponseInfo] networkName: %@, adUnitId: %@, placement: %@, revenue: %.4f (%@), dspName: %@, format: %@",
                networkName, adUnitId, placement, revenue, revenuePrecision, dspName, format);
}

+ (NSDictionary *)adNetworkInfoFromAd:(MAAd *)ad {
    NSString *networkName       = [ad networkName] ?: @"";
    NSString *placement         = [ad placement] ?: @"";
    double revenue              = [ad revenue] >= 0 ? [ad revenue] : 0.0;
    NSString *revenuePrecision  = [ad revenuePrecision] ?: @"";
    NSString *dspName           = [ad DSPName] ?: @"";
    NSString *format            = [ad.format label];
    return @{
        @"networkName"      : networkName,
        @"placement"        : placement,
        @"revenue"          : @(revenue),
        @"revenuePrecision" : revenuePrecision,
        @"dspName"          : dspName,
        @"adFormat"         : [format length] > 0 ? format : @""
    };
}

@end
