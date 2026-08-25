//
//  AdPieResponse.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "AdPieResponse.h"

@implementation AdPieResponse

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super initWithDictionary:dictionary]) {
        _result = [self intForKey:@"result"];
        _message = [self stringForKey:@"message"];
        
        NSDictionary *dict = [self dictionaryForKey:@"data"];
        
        if (dict == nil) {
            return self;
        }
        
        ADXObject *data = [[ADXObject alloc] initWithDictionary:dict];
        _refresh = [data boolForKey:@"refresh"];
        _interval = [data longForKey:@"interval"];
        _limit = [data longForKey:@"limit"];
        _count = [data intForKey:@"count"];
        
        NSDictionary *adDict = [data dictionaryForKey:@"ad"];
        if (adDict == nil || adDict.count == 0) {
            return self;
        }
            
        AdPieAdContentType icType = (AdPieAdContentType)[[adDict objectForKey:@"ictype"] integerValue];
        switch(icType)
        {
        case AdPieAdContentTypeBannerImage:
        case AdPieAdContentTypeInterstitalImage:
            _adData = [[AdPieAdData alloc] initWithDictionary:adDict];
            break;
        case AdPieAdContentTypeNativeImage:
            _adData = [[AdPieNativeAdData alloc] initWithDictionary:adDict];
            break;
        case AdPieAdContentTypeInterstitialIVideo:
        case AdPieAdContentTypeRewardedVideo:
        case AdPieAdContentTypePrerollVideo:
            _adData = [[AdPieVideoAdData alloc] initWithDictionary:adDict];
            break;
        default:
            break;
        }
    }
    
    return self;
}

@end
