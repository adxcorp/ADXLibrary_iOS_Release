//
//  ADXAdConstants.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *ADXAdNetwork;
extern ADXAdNetwork const ADXAdNetworkADX;
extern ADXAdNetwork const ADXAdNetworkAdMob;
extern ADXAdNetwork const ADXAdNetworkAdManager;
extern ADXAdNetwork const ADXAdNetworkAdPie;
extern ADXAdNetwork const ADXAdNetworkAppLovin;
extern ADXAdNetwork const ADXAdNetworkCauly;
extern ADXAdNetwork const ADXAdNetworkFacebook;
extern ADXAdNetwork const ADXAdNetworkFyber;
extern ADXAdNetwork const ADXAdNetworkPangle;
extern ADXAdNetwork const ADXAdNetworkTapjoy;
extern ADXAdNetwork const ADXAdNetworkUnityAds;

typedef NSString *ADXAdType;
extern ADXAdType const ADXAdTypeBanner;
extern ADXAdType const ADXAdTypeInterstitial;
extern ADXAdType const ADXAdTypeNative;
extern ADXAdType const ADXAdTypeNativeBanner;
extern ADXAdType const ADXAdTypeNativeInterstitial;
extern ADXAdType const ADXAdTypeRewarded;
extern ADXAdType const ADXAdTypeRewardedInterstitial;

typedef NSString *ADXAdEvent;
extern ADXAdEvent const ADXAdEventLoad;
extern ADXAdEvent const ADXAdEventLoadSuccess;
extern ADXAdEvent const ADXAdEventLoadFailed;
extern ADXAdEvent const ADXAdEventShow;
extern ADXAdEvent const ADXAdEventShowFailed;
extern ADXAdEvent const ADXAdEventImpression;
extern ADXAdEvent const ADXAdEventClick;
extern ADXAdEvent const ADXAdEventReward;
extern ADXAdEvent const ADXAdEventClose;

typedef CGSize ADXAdSize;
extern ADXAdSize const ADXAdSizeBanner; // 320x50
extern ADXAdSize const ADXAdSizeLargeBanner; // 320x100
extern ADXAdSize const ADXAdSizeMediumRectangle; // 300x250
extern ADXAdSize const ADXAdSizeLeaderboard; // 728x90
extern ADXAdSize ADXAdSizeMake(CGFloat width, CGFloat height);
extern CGSize CGSizeFromADXAdSize(ADXAdSize size);

NS_ASSUME_NONNULL_END
