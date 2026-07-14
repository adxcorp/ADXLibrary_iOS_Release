//
//  AdPieEndCardData.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <ADXLibrary/ADXAdLogEvent.h>
#import "AdPieEndCardData.h"

@implementation AdPieEndCardData

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _width = dict[@"width"] ? [dict[@"width"] integerValue] : -1;
        _height = dict[@"height"] ? [dict[@"height"] integerValue] : -1;
        _staticResource = dict[@"static_resource"] ?: @"";
        _htmlResource = dict[@"html_resource"] ?: @"";
        _iframeResource = dict[@"iframe_resource"] ?: @"";
        _clickThrough = dict[@"click_through"] ?: @"";
        _clickTracking = dict[@"click_tracking"] ?: @[];
        _creativeView = dict[@"creative_view"] ?: @[];
        ADXDebugLog(@"EndCard, _width : %ld", _width);
        ADXDebugLog(@"EndCard, _height : %ld", _height);
        ADXDebugLog(@"EndCard, _staticResource : %@", _staticResource);
        ADXDebugLog(@"EndCard, _htmlResource : %@", _htmlResource);
        ADXDebugLog(@"EndCard, _iframeResource : %@", _iframeResource);
        ADXDebugLog(@"EndCard, _clickThrough : %@", _clickThrough);
        ADXDebugLog(@"EndCard, _creativeView : %@", _creativeView);
    }
    return self;
}

@end

