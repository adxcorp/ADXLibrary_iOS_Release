//
//  ADXSdk.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ADXConfiguration.h"
#import "ADXGdprConstants.h"

#define ADX_SDK_VERSION @"2.5.6.5"

NS_ASSUME_NONNULL_BEGIN

@interface ADXSdk : NSObject

typedef void(^ADXCompletionHandler)(BOOL result, ADXConsentState consentState);

@property (strong, readonly) NSString *appId;
@property (assign, readonly) ADXGdprType gdprType;
@property (assign, readonly, getter=isInitialized) BOOL initialized;

+ (instancetype)sharedInstance;

- (void)initializeWithConfiguration:(ADXConfiguration *)configuration
                  completionHandler:(nullable ADXCompletionHandler)completionHandler;

// This method should only be called in response to a user input to request a privacy options form to be shown.
- (void)showGDPRForm:(UIViewController * __nullable)viewController completionHandler:(void (^)(BOOL))completionHandler;

@end

NS_ASSUME_NONNULL_END
