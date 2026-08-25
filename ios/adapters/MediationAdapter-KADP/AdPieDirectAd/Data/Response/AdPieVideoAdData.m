//
//  AdPieVideoAdData.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "AdPieVideoAdData.h"

@implementation AdPieVideoAdData

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super initWithDictionary:dictionary]) {
        NSDictionary *dict = [self dictionaryForKey:@"video"];
        
        if (dict != nil) {
            ADXObject *video = [[ADXObject alloc] initWithDictionary:dict];
            _title = [video stringForKey:@"title"];
            _desc = [video stringForKey:@"description"];
            _skipOffset = [video intForKey:@"skip_offset"];
            _autoplay = [video intForKey:@"autoplay"];
            _duration = [video intForKey:@"duration"];
            _link = [video stringForKey:@"link"];
            _linkText = [video stringForKey:@"link_text"];
            _content = [video stringForKey:@"content"];
            _contentType = [video stringForKey:@"content_type"];
            _delivery = [video intForKey:@"delivery"];
            _contentWidth = [video intForKey:@"content_width"];
            _contentHeight = [video intForKey:@"content_height"];
            _optoutImageURL = [video stringForKey:@"optout_img"];
            _optoutLinkURL = [video stringForKey:@"optout_link"];
            
            NSDictionary *trackerDict = [video dictionaryForKey:@"trackers"];
            if (trackerDict != nil) {
                ADXObject *tracker = [[ADXObject alloc] initWithDictionary:trackerDict];
                self.trackImpressionURLs = [tracker arrayForKey:@"impression"];
                self.trackClickURLs = [tracker arrayForKey:@"click"];
                _trackingStartUrls = [tracker arrayForKey:@"start"];
                _trackingFirstQuartileUrls = [tracker arrayForKey:@"first_quartile"];
                _trackingMidpointUrls = [tracker arrayForKey:@"midpoint"];
                _trackingThirdQuartileUrls = [tracker arrayForKey:@"third_quartile"];
                _trackingCompleteUrls = [tracker arrayForKey:@"complete"];
            }
            
            NSArray * endCardArray = [video objectForKey:@"end_card"];
            if ([endCardArray count]) {
                NSDictionary * dictionary = (NSDictionary *)[endCardArray firstObject];
                _endCard = [[AdPieEndCardData alloc] initWithDictionary:dictionary];
            }
        }
    }
    
    return self;
}

@end
