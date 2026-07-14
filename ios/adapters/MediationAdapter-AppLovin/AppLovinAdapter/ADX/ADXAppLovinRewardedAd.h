//
//  ADXAppLovinRewardedAd.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ADXLibrary/ADXMediationAd.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADXAppLovinRewardedAd : NSObject <ADXMediationRewardedAd>

@property (weak) id<ADXMediationRewardedAd> __nullable loadedAd;
@property (strong, nullable) NSDictionary *adNetworkInfo;

@end

NS_ASSUME_NONNULL_END
