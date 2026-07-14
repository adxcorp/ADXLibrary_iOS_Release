//
//  AdPieResponse.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ADXLibrary/ADXObject.h>
#import "AdPieAdData.h"
#import "AdPieNativeAdData.h"
#import "AdPieVideoAdData.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdPieResponse : ADXObject

@property (readonly, assign) int result;
@property (readonly, copy) NSString *message;

@property (readonly, assign) BOOL refresh;
@property (readonly, assign) long interval;
@property (readonly, assign) long limit;
@property (readonly, assign) int count;

@property (readonly, copy) AdPieAdData *adData;

@end

NS_ASSUME_NONNULL_END
