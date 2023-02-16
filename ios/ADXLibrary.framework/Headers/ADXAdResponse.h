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

@property (nonatomic, readonly, copy) NSString *requestId;
@property (nonatomic, readonly, copy) NSString *metricEndpointFormat;
@property (nonatomic, readonly, assign) BOOL enableBiddingKit;
@property (nonatomic, readonly, assign) double biddingKitEcpm;
@property (nonatomic, readonly, copy) NSString *biddingKitAdUnitId;
@property (nonatomic, readonly, copy) NSString *biddingKitMediationId;
@property (nonatomic, readonly, assign) long bannerRefreshInterval;
@property (nonatomic, readonly, assign) BOOL debuggable;
@property (nonatomic, readonly, strong) NSArray<ADXMediationData *> *mediations;

@end

NS_ASSUME_NONNULL_END
