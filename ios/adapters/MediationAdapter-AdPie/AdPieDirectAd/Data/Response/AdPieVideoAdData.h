//
//  AdPieVideoAdData.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdPieAdData.h"
#import "AdPieEndCardData.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdPieVideoAdData : AdPieAdData

@property (readonly, copy) NSString *title;
@property (readonly, copy) NSString *desc;
@property (readonly, assign) int skipOffset;
@property (readonly, assign) int autoplay;
@property (readonly, assign) int duration;
@property (readonly, copy) NSString *link;
@property (readonly, copy) NSString *linkText;
@property (readonly, copy) NSString *content;
@property (readonly, copy) NSString *contentType;
@property (readonly, copy) NSString *optoutImageURL;
@property (readonly, copy) NSString *optoutLinkURL;
@property (readonly, assign) int delivery;
@property (readonly, assign) int contentWidth;
@property (readonly, assign) int contentHeight;

@property (readonly, strong) NSArray *trackingStartUrls;
@property (readonly, strong) NSArray *trackingFirstQuartileUrls;
@property (readonly, strong) NSArray *trackingMidpointUrls;
@property (readonly, strong) NSArray *trackingThirdQuartileUrls;
@property (readonly, strong) NSArray *trackingCompleteUrls;

@property (readonly, strong) AdPieEndCardData * __nullable endCard;

@end

NS_ASSUME_NONNULL_END
