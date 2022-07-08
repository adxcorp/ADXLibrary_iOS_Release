//
//  ADXMediationAdapter.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADXLog.h"
#import "ADXAdError.h"
#import "ADXMediationData.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ADXMediationAdapterCompletionHandler)(BOOL success, NSError * _Nullable error);

@protocol ADXMediationAdapter <NSObject>

+ (NSString *)adapterVersion;
+ (NSString *)networkSdkVersion;

@optional
+ (void)initializeSdkWithConfiguration:(nullable NSDictionary *)configuration;
+ (void)initializeSdkWithConfiguration:(nullable NSDictionary *)configuration completionHandler:(nullable ADXMediationAdapterCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
