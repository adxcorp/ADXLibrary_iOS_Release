//
//  ADXConfiguration.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADXGdprConstants.h"
#import "ADXLogLevel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ADXConfiguration : NSObject

@property (nonatomic, strong, readonly) NSString *appId;
@property (nonatomic, assign, readonly) ADXGdprType gdprType;

@property (nonatomic, assign) ADXLogLevel logLevel;

- (instancetype)initWithAppId:(NSString *)appId gdprType:(ADXGdprType)gdprType NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END