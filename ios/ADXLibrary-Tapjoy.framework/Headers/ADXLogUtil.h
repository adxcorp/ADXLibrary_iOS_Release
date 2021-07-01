//
//  ADXLogUtil.h
//  ADXLibrary
//
//  Created by sunny on 2020/08/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define ADX_PLATFORM_ADCOLONY @"AdColony"
#define ADX_PLATFORM_ADFIT @"AdFit"
#define ADX_PLATFORM_ADPIE @"AdPie"
#define ADX_PLATFORM_CAULY @"Cauly"
#define ADX_PLATFORM_FACEBOOK @"FAN"
#define ADX_PLATFORM_ADMOB @"AdMob"
#define ADX_PLATFORM_IRONSOURCE @"ironSource"
#define ADX_PLATFORM_MOPUB @"MoPub"
#define ADX_PLATFORM_PANGLE @"Pangle"
#define ADX_PLATFORM_UNITYADS @"UnityAds"
#define ADX_PLATFORM_VUNGLE @"Vungle"
#define ADX_PLATFORM_TAPJOY @"Tapjoy"

#define ADX_INVENTORY_BANNER @"Banner"
#define ADX_INVENTORY_INTERSTITIAL @"Interstitial"
#define ADX_INVENTORY_NATIVE @"Native"
#define ADX_INVENTORY_RV @"RewardedVideo"

#define ADX_EVENT_LOAD @"Load"
#define ADX_EVENT_LOAD_SUCCESS @"Success"
#define ADX_EVENT_LOAD_FAILURE @"Failure"
#define ADX_EVENT_IMPRESSION @"Impression"
#define ADX_EVENT_CLICK @"Click"
#define ADX_EVENT_REWARD @"Reward"
#define ADX_EVENT_CLOSED @"Closed"

#ifdef DEBUG
#define ADXLogEvent(platform, inventory, event) NSLog(@"AD(X)[%@|%@]: %@", platform, inventory, event)
#else
#define ADXLogEvent(platform, inventory, event) ((void)0)
#endif

NS_ASSUME_NONNULL_END
