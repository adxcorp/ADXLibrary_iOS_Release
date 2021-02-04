//
//  CaulyInterstitialCustomEvent.h
//  ADXLibrary
//
//  Created by sunny on 2021/01/19.
//

#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDK/MoPub.h>)
#import <MoPubSDK/MoPub.h>
#else
#import "MPFullscreenAdAdapter.h"
#import "MPLogging.h"
#endif

@interface CaulyInterstitialCustomEvent : MPFullscreenAdAdapter <MPThirdPartyFullscreenAdAdapter>

@end
