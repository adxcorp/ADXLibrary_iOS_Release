//
//  ADXSdk.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADXConfiguration.h"
#import "ADXGdprConstants.h"

#define ADX_SDK_VERSION @"2.0.0-beta4"

NS_ASSUME_NONNULL_BEGIN

@interface ADXSdk : NSObject

typedef void(^ADXCompletionHandler)(BOOL result, ADXConsentState consentState);

@property (nonatomic, strong, readonly) NSString *appId;
@property (nonatomic, assign, readonly, getter=isInitialized) BOOL initialized;

+ (instancetype)sharedInstance;

+ (NSString *)sdkVersion;

- (void)initializeWithConfiguration:(ADXConfiguration *)configuration completionHandler:(nullable ADXCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END