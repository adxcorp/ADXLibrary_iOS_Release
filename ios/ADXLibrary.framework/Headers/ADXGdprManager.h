//
//  ADXGdprManager.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADXGdprConstants.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ADXConsentCompletionHandler)(ADXConsentState consentState);
typedef void(^ADXLocateCompletionHandler)(ADXLocate locate);

@interface ADXGdprManager : NSObject

@property (nonatomic, strong, readonly) NSURL *privacyPolicyURL;
@property (nonatomic, assign) ADXConsentState consentState;
@property (nonatomic, assign, readonly) BOOL isConsentStateConfirm;

+ (instancetype)sharedInstance;

- (void)initWithGdprType:(ADXGdprType)gdprType completionHandler:(ADXConsentCompletionHandler)completionHandler;
- (void)checkInEEAorUnknownWithCompletionHandler:(ADXLocateCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
