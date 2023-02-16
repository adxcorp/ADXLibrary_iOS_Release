//
//  ADXMediationData.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADXObject.h"
#import "ADXAdConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface ADXMediationData : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSMutableDictionary *)dictionary;

@property (nonatomic, readonly, copy) NSString *adType;
@property (nonatomic, readonly, copy) NSString *requestId;
@property (nonatomic, readonly, copy) NSString *adNetworkName;
@property (nonatomic, readonly, copy) NSString *mediationId;
@property (nonatomic, readonly, copy, nullable) NSString *customEventName;
@property (nonatomic, readonly, strong) NSDictionary *customEventParams;
@property (nonatomic, readonly, strong) NSDictionary *bidResponse;
@property (nonatomic, readonly, assign) double ecpm;
@property (nonatomic, readonly, copy) NSString *metricEndpointFormat;

// biddingKit
@property (nonatomic, assign) BOOL enableBiddingKit;
@property (nonatomic, readonly, copy) NSString *biddingKitAdUnitId;
@property (nonatomic, readonly, copy) NSString *biddingKitMediationId;

@end

NS_ASSUME_NONNULL_END
