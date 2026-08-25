//
//  AdPieNativeAdData.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AdPieAdData.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdPieNativeAdData : AdPieAdData

@property (readonly, strong) NSArray *assetType;
@property (readonly, copy) NSString *title;
@property (readonly, copy) NSString *desc;
@property (readonly, copy) NSString *iconImageUrl;
@property (readonly, copy) NSString *mainImageUrl;
@property (readonly, copy) NSString *callToAction;
@property (readonly, assign) double rating;
@property (readonly, assign) int iconWidth;
@property (readonly, assign) int iconHeight;
@property (readonly, copy) NSString *link;
@property (readonly, copy) NSString *optoutImageUrl;
@property (readonly, copy) NSString *optoutLink;
@property (readonly, assign) int onlyClickCTA;

@end

NS_ASSUME_NONNULL_END
