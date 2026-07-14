//
//  ADXUnityAdsAdapter.h
//  ADXLibrary-UnityAds
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ADXLibrary/ADXMediationAdapter.h>
#import <UnityAds/UnityAds.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const ADXUnityAdsErrorDomain;

@interface ADXUnityAdsAdapter : NSObject <ADXMediationAdapter>

+ (instancetype)sharedInstance;
- (void)setGDPRConsentState;

@end

NS_ASSUME_NONNULL_END
