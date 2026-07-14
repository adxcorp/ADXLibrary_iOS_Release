//
//  ADXAdMobAdapter.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ADXLibrary/ADXMediationAdapter.h>

#import <GoogleMobileAds/GoogleMobileAds.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const ADXAdMobErrorDomain;
extern NSString *const ADXAdManagerErrorDomain;

@interface ADXAdMobAdapter : NSObject <ADXMediationAdapter>

+ (GADRequest *)gdprGADRequest;
+ (GAMRequest *)gdprGAMRequest;
+ (void)printAdNetworkResponseInfo:(GADResponseInfo *)info;

@end

NS_ASSUME_NONNULL_END
