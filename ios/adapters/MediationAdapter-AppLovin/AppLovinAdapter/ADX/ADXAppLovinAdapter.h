//
//  ADXAppLovinAdapter.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ADXLibrary/ADXMediationAdapter.h>
#import <AppLovinSDK/AppLovinSDK.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const ADXAppLovinErrorDomain;
extern NSString *const ADXAppLovinBiddingKitKey;
extern NSString *const ADXAppLovinSdkKey;

@interface ADXAppLovinAdapter : NSObject <ADXMediationAdapter>

+ (ALSdk *)appLovinSdk;
+ (void)setGDPRConsentState;
+ (NSString *)getAppLovinAdUnitIDs:(NSString *)adUnitID;
+ (void)printAdNetworkResponseInfo:(MAAd *)ad;
+ (NSDictionary *)adNetworkInfoFromAd:(MAAd *)ad;
@end

NS_ASSUME_NONNULL_END
