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

@interface ADXMediationData : ADXObject

@property (nonatomic, readonly, copy) NSString *adType;
@property (nonatomic, readonly, copy) NSString *requestId;
@property (nonatomic, readonly, copy) NSString *adNetworkName;
@property (nonatomic, readonly, copy) NSString *mediationId;
@property (nonatomic, readonly, copy, nullable) NSString *customEventName;
@property (nonatomic, readonly, copy, nullable) NSDictionary *customEventParams;
@property (nonatomic, readonly, copy, nullable) NSDictionary *bidResponse;
@property (nonatomic, readonly, assign) double ecpm;
@property (nonatomic, readonly, copy) NSString *metricEndpointFormat;

@end

NS_ASSUME_NONNULL_END
