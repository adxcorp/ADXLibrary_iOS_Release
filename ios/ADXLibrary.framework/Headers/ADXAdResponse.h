//
//  ADXAdResponse.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADXObject.h"
#import "ADXMediationData.h"

NS_ASSUME_NONNULL_BEGIN

@interface ADXAdResponse : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@property (readonly, copy) NSString *requestId;
@property (readonly, copy) NSString *metricEndpointFormat;
@property (readonly, assign) BOOL enableBiddingKit;
@property (readonly, assign) double biddingKitEcpm;
@property (readonly, assign) NSInteger requestTimeout;
@property (readonly, copy) NSString *biddingKitAdUnitId;
@property (readonly, copy) NSString *biddingKitMediationId;
@property (readonly, assign) long bannerRefreshInterval;
@property (readonly, assign) BOOL debuggable;
@property (readonly, strong) NSArray<ADXMediationData *> *mediations;

@end

NS_ASSUME_NONNULL_END
