//
//  ADXUnityAdsAdapter.m
//  ADXLibrary-UnityAds
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "ADXUnityAdsAdapter.h"

#import <ADXLibrary/ADXGdprManager.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>

NSString *const ADXUnityAdsErrorDomain = @"com.adx.sdk.mediation.unityads";
static NSString *const ADXUnityAdsGameIdKey = @"game_id";

@interface ADXUnityAdsAdapterInitializationDelegate : NSObject <UnityAdsInitializationDelegate>

@property (nonatomic, copy) void (^initializationCompleteBlock)(void);
@property (nonatomic, copy) void (^initializationFailedBlock)(int error, NSString *message);

@end

@implementation ADXUnityAdsAdapterInitializationDelegate

- (void)initializationComplete {
    if (self.initializationCompleteBlock) {
        self.initializationCompleteBlock();
    }
}

- (void)initializationFailed:(UnityAdsInitializationError)error withMessage:(nonnull NSString *)message {
    if (self.initializationFailedBlock) {
        self.initializationFailedBlock(kUnityInitializationErrorInternalError, message);
    }
}

@end

@implementation ADXUnityAdsAdapter

typedef NS_ENUM(NSInteger, ADXUnityAdsInitState) {
    ADXUnityAdsInitStateNotStarted,
    ADXUnityAdsInitStateInitializing,
    ADXUnityAdsInitStateInitialized,
    ADXUnityAdsInitStateFailed,
};

static ADXUnityAdsInitState adxUnityInitState = ADXUnityAdsInitStateNotStarted;
static NSError *adxUnityInitError = nil;
static NSMutableArray *adxUnityPendingHandlers = nil;
static dispatch_queue_t adxUnityStateQueue;

/// 공유 상태(대기 핸들러, 직렬 큐)를 싱글톤 생성과 독립적으로 초기화
+ (void)initializeSharedState {
    static dispatch_once_t sharedStateToken;
    dispatch_once(&sharedStateToken, ^{
        adxUnityPendingHandlers = [NSMutableArray array];
        adxUnityStateQueue = dispatch_queue_create("com.adx.unityads.stateQueue", DISPATCH_QUEUE_SERIAL);
    });
}

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self initializeSharedState];
        sharedInstance = [self new];
    });
    return sharedInstance;
}

+ (NSString *)adapterVersion {
    return @"4.18.1.0";
}

+ (NSString *)networkSdkVersion {
    return [UnityAds getVersion];
}

+ (void)initializeSdkWithConfiguration:(nullable NSDictionary *)configuration
                     completionHandler:(nullable ADXMediationAdapterCompletionHandler)completionHandler {
    [[ADXUnityAdsAdapter sharedInstance] initializeSdkWithConfiguration:configuration
                                                      completionHandler:completionHandler];
}

- (void)initializeSdkWithConfiguration:(nullable NSDictionary *)configuration
                     completionHandler:(nullable ADXMediationAdapterCompletionHandler)completionHandler {
    NSString *gameId = configuration[ADXUnityAdsGameIdKey];
    ADXLogDebug(@"Unity Ads Game ID: %@", gameId);

    if (gameId == nil || [gameId length] == 0) {
        NSError *error = [NSError errorWithDomain:ADXUnityAdsErrorDomain
                                             code:ADXAdErrorSdkNotInitialize
                                      description:@"Unity Ads initialization failed. The gameId is empty."];
        [self finishCompletionHandler:NO error:error completionHandler:completionHandler];
        return;
    }

    dispatch_async(adxUnityStateQueue, ^{
        // 이미 초기화 완료된 경우 즉시 콜백
        if (adxUnityInitState == ADXUnityAdsInitStateInitialized) {
            ADXLogInfo(@"Unity Ads SDK (v%@) initialized.", ADXUnityAdsAdapter.networkSdkVersion);
            [self finishCompletionHandler:YES error:nil completionHandler:completionHandler];
            return;
        }

        // 이미 초기화 실패한 경우 즉시 콜백
        if (adxUnityInitState == ADXUnityAdsInitStateFailed) {
            [self finishCompletionHandler:NO error:adxUnityInitError completionHandler:completionHandler];
            return;
        }

        // 콜백을 대기열에 추가
        if (completionHandler) {
            [adxUnityPendingHandlers addObject:completionHandler];
        }

        // 이미 초기화 중이면 대기
        if (adxUnityInitState == ADXUnityAdsInitStateInitializing) {
            return;
        }

        // 초기화 시작
        adxUnityInitState = ADXUnityAdsInitStateInitializing;

        dispatch_async(dispatch_get_main_queue(), ^{
            [self setGDPRConsentState];
        });

        ADXUnityAdsAdapterInitializationDelegate *initDelegate = [[ADXUnityAdsAdapterInitializationDelegate alloc] init];

        // 성공 콜백
        initDelegate.initializationCompleteBlock = ^{
            ADXLogInfo(@"Unity Ads SDK (v%@) initialized successfully.", ADXUnityAdsAdapter.networkSdkVersion);
            dispatch_async(adxUnityStateQueue, ^{
                adxUnityInitState = ADXUnityAdsInitStateInitialized;
                adxUnityInitError = nil;
                NSArray *handlers = [adxUnityPendingHandlers copy];
                [adxUnityPendingHandlers removeAllObjects];
                for (id handler in handlers) {
                    [self finishCompletionHandler:YES error:nil completionHandler:handler];
                }
            });
        };

        // 실패 콜백
        initDelegate.initializationFailedBlock = ^(int error, NSString *message) {
            ADXLogInfo(@"Unity Ads SDK (v%@) initialization failed (%@)", ADXUnityAdsAdapter.networkSdkVersion, message);
            NSError *initError = [NSError errorWithDomain:ADXUnityAdsErrorDomain
                                                     code:ADXAdErrorSdkNotInitialize
                                              description:message];
            dispatch_async(adxUnityStateQueue, ^{
                adxUnityInitState = ADXUnityAdsInitStateFailed;
                adxUnityInitError = initError;
                NSArray *handlers = [adxUnityPendingHandlers copy];
                [adxUnityPendingHandlers removeAllObjects];
                for (id handler in handlers) {
                    [self finishCompletionHandler:NO error:initError completionHandler:handler];
                }
            });
        };

        // 디버그 모드
        BOOL debugMode = [ADXLog sharedInstance].logLevel == ADXLogLevelVerbose;
        [UnityAds setDebugMode:debugMode];

        // UnityAds 초기화 메소드 호출
#ifdef DEBUG
        [UnityAds initialize:gameId
                    testMode:[ADXLog sharedInstance].debuggable
      initializationDelegate:initDelegate];
#else
        [UnityAds initialize:gameId
                    testMode:NO
      initializationDelegate:initDelegate];
#endif
    });
}

- (void)setGDPRConsentState {
    ADXConsentState consentState = [ADXGdprManager sharedInstance].consentState;
    UADSMetaData *gdprConsentMetaData = [[UADSMetaData alloc] init];
    
    if (consentState == ADXConsentStateConfirm) {
        [gdprConsentMetaData set:@"gdpr.consent" value:@YES];
    } else if (consentState == ADXConsentStateDenied) {
        [gdprConsentMetaData set:@"gdpr.consent" value:@NO];
    } else {
        if (@available(iOS 14.0, *)) {
            if (ATTrackingManager.trackingAuthorizationStatus == ATTrackingManagerAuthorizationStatusAuthorized) {
                [gdprConsentMetaData set:@"gdpr.consent" value:@YES];
            } else {
                [gdprConsentMetaData set:@"gdpr.consent" value:@NO];
            }
        } else {
            [gdprConsentMetaData set:@"gdpr.consent" value:@YES];
        }
    }
    [gdprConsentMetaData commit];
}

- (void)finishCompletionHandler:(BOOL)result
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

@end
