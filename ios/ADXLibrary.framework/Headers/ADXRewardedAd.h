//
//  ADXRewardedAd.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ADXReward.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ADXRewardedAdDelegate;

@interface ADXRewardedAd : NSObject

@property (nonatomic, copy, readonly) NSString *adUnitId;
@property (nonatomic, weak, nullable) id<ADXRewardedAdDelegate> delegate;
@property (nonatomic, assign, readonly, getter=isLoaded) BOOL loaded;

- (instancetype)initWithAdUnitId:(NSString *)adUnitId NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)decoder NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (void)loadAd;
- (void)showAdFromRootViewController:(UIViewController *)rootViewController;

@end

@protocol ADXRewardedAdDelegate <NSObject>

@optional
- (void)rewardedAdDidLoad:(ADXRewardedAd *)rewardedAd;
- (void)rewardedAd:(ADXRewardedAd *)rewardedAd didFailToLoadWithError:(NSError *)error;
- (void)rewardedAd:(ADXRewardedAd *)rewardedAd didFailToShowWithError:(NSError *)error;
- (void)rewardedAdWillPresentScreen:(ADXRewardedAd *)rewardedAd;
- (void)rewardedAdWillDismissScreen:(ADXRewardedAd *)rewardedAd;
- (void)rewardedAdDidDismissScreen:(ADXRewardedAd *)rewardedAd;
- (void)rewardedAdDidRewardUser:(ADXRewardedAd *)rewwaredAd withReward:(ADXReward *)reward;
- (void)rewardedAdDidClick:(ADXRewardedAd *)rewwaredAd;

@end

NS_ASSUME_NONNULL_END
