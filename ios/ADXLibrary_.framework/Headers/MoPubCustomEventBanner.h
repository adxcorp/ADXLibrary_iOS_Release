//
//  MoPubCustomEventBanner.h
//  ADXLibrary
//
//  Created by sunny on 2020/08/13.
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
    #import <MoPubSDK/MoPub.h>
#else
    #import "MoPub.h"
    #import "MPAdView.h"
    #import "MPLogging.h"
#endif

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

NS_ASSUME_NONNULL_BEGIN

@interface MoPubCustomEventBanner : NSObject<GADCustomEventBanner>

@end

NS_ASSUME_NONNULL_END
