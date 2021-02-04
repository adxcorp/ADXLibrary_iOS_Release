//
//  FacebookNativeBannerCustomEvent.h
//  ADXLibrary
//
//  Created by sunny on 2021/01/25.
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
    #import <MoPubSDK/MoPub.h>
#else
    #import "MPNativeCustomEvent.h"
#endif


@interface FacebookNativeBannerCustomEvent : MPNativeCustomEvent

@end
