//
//  ADXAdInfo.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADXAdInfo : NSObject

@property (nonatomic, copy, readonly, nullable) NSString *adUnitIdentifier;
@property (nonatomic, copy, readonly, nullable) NSString *adFormat;
@property (nonatomic, assign, readonly) double revenue;
@property (nonatomic, assign, readonly) double eCPM;
@property (nonatomic, copy, readonly, nullable) NSString *networkName;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
