//
//  AdPieInterstitialCustomEvent.h
//  ADXLibrary
//
//  Created by 최치웅 on 2018. 12. 21..
//

#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
#import <MoPubSDK/MoPub.h>
#else
#import "MPFullscreenAdAdapter.h"
#import "MPLogging.h"
#endif

@interface AdPieInterstitialCustomEvent : MPFullscreenAdAdapter <MPThirdPartyFullscreenAdAdapter>

@end
