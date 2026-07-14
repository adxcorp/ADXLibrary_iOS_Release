//
//  ADXAppLovinBannerAd.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <ADXLibrary/ADXMediationAd.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADXAppLovinBannerAd : NSObject <ADXMediationBannerAd>

@property (weak) id<ADXMediationBannerAd> __nullable loadedAd;
@property (weak) UIView * __nullable bannerView;
@property (strong, nullable) NSDictionary *adNetworkInfo;

@end

NS_ASSUME_NONNULL_END
