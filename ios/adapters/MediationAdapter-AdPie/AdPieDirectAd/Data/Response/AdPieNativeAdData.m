//
//  AdPieNativeAdData.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "AdPieNativeAdData.h"

@implementation AdPieNativeAdData

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super initWithDictionary:dictionary]) {
        NSDictionary *dict = [self dictionaryForKey:@"native"];
        
        if (dict != nil) {
            ADXObject *native = [[ADXObject alloc] initWithDictionary:dict];
            _assetType = [native arrayForKey:@"assettype"];
            _title = [native stringForKey:@"title"];
            _desc = [native stringForKey:@"desc"];
            _iconImageUrl = [native stringForKey:@"img_icon"];
            _mainImageUrl = [native stringForKey:@"img_main"];
            
            if (self.icType == AdPieAdContentTypeNativeImage) {
                _callToAction = [native stringForKey:@"cta"];
                
            } else if (self.icType == AdPieAdContentTypeNativeVideo) {
                _callToAction = [native stringForKey:@"link_text"];
            }
            _link = [native stringForKey:@"link"];
            _rating = [native dobuleForKey:@"rating"];
            
            self.trackImpressionURLs = [native arrayForKey:@"imptrackers"];
            self.trackClickURLs = [native arrayForKey:@"clicktrackers"];
            
            _optoutImageUrl = [native stringForKey:@"optout_img"];
            _optoutLink = [native stringForKey:@"optout_link"];
            
            _onlyClickCTA = [native intForKey:@"ck_cta"];
        }
    }
    
    return self;
}

@end
