//
//  ADXAppLovinNativeAd.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ADXLibrary/ADXMediationAd.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADXAppLovinNativeAd : NSObject <ADXMediationNativeAd>

@property (weak) id<ADXMediationNativeAd> __nullable loadedAd;

@end

NS_ASSUME_NONNULL_END
