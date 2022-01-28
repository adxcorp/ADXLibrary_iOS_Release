//
//  ADXGDPR.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADXGdprConstants.h"

typedef NS_ENUM(NSInteger, ADXDebugState) {
    ADXDebugLocateDefault       = 0,
    ADXDebugLocateInEEA         = 1,
    ADXDebugLocateNotEEA        = 2,
}; DEPRECATED_MSG_ATTRIBUTE("ADXDebugState is deprecated. Please use ADXGdprType instead.")

typedef void(^ADXConsentCompletionBlock)(ADXConsentState consentState, BOOL success);
typedef void (^ADXConsentInformationUpdateHandler)(ADXLocate locate);
typedef void(^ADXUserConfirmedBlock)(BOOL);

DEPRECATED_MSG_ATTRIBUTE("ADXGDPR is deprecated. Please use ADXSdk instead.")
@interface ADXGDPR : NSObject

@property (nonatomic, assign) ADXDebugState debugState;
@property(nonatomic) BOOL logEnable;


/**
 get instance

 @return ADXGDPR instance
 */
+ (ADXGDPR *)sharedInstance;

/**
 check and show consent

 @param completionBlock consentState, success
 */
- (void)showADXConsent:(ADXConsentCompletionBlock)completionBlock;

/**
 check locate

 @param handler comletion with ADXLocate
 */
- (void)checkInEEAorUnknown:(ADXConsentInformationUpdateHandler)handler;

/**
 read consent state

 @return ADXConsentState
 */
- (ADXConsentState)getConsentState;

/**
 change consent state

 @param state ADXConsentState
 */
- (void)setConsentState:(ADXConsentState)state;

/**
 get ADX privacy policy url

 @return URL
*/
- (NSURL *)getPrivacyPolicyURL;

@end
