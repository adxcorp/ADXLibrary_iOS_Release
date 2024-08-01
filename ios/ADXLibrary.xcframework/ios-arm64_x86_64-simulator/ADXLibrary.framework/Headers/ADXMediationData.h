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
- (NSDictionary *)dictionary;

@property (readonly, copy) NSString *adType;
@property (readonly, copy) NSString *requestId;
@property (readonly, copy) NSString *adNetworkName;
@property (readonly, copy) NSString *mediationId;
@property (readonly, copy, nullable) NSString *customEventName;
@property (readonly, strong) NSDictionary *customEventParams;
@property (readonly, strong) NSDictionary *bidResponse;
@property (assign) BOOL usePaidEventHandler;
@property (assign) double ecpm;
@property (readonly, copy) NSString *metricEndpointFormat;

// biddingKit
@property (nonatomic, assign) BOOL enableBiddingKit;
@property (readonly, copy) NSString *biddingKitAdUnitId;
@property (readonly, copy) NSString *biddingKitMediationId;
@property (readonly, copy) NSString * biddingPlatform;

@end

NS_ASSUME_NONNULL_END
