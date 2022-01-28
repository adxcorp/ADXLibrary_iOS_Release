//
//  ADXMediationAdapter.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADXLogger.h"
#import "ADXAdError.h"
#import "ADXMediationData.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ADXMediationAdapter <NSObject>

+ (NSString *)adapterVersion;
+ (NSString *)networkSdkVersion;

+ (void)initializeSdkWithConfiguration:(nullable NSDictionary *)configuration;

@end


NS_ASSUME_NONNULL_END
