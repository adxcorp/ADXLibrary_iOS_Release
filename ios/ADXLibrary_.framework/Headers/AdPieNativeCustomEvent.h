//
//  AdPieNativeCustomEvent.h
//  ADXLibrary
//
//  Created by 최치웅 on 12/08/2019.
//

#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
#import <MoPubSDK/MoPub.h>
#else
#import "MPNativeCustomEvent.h"
#endif

@interface AdPieNativeCustomEvent : MPNativeCustomEvent

@end
