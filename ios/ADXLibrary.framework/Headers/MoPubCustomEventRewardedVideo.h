//
//  MoPubCustomEventRewardedVideo.h
//  ADXLibrary
//
//  Created by 최치웅 on 2019. 1. 18..
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
    #import <MoPubSDK/MoPub.h>
#else
    #import "MoPub.h"
    #import "MPRewardedVideo.h"
    #import "MPLogging.h"
#endif

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <Foundation/Foundation.h>

@interface MoPubCustomEventRewardedVideo : NSObject<GADMediationAdapter>

@end
