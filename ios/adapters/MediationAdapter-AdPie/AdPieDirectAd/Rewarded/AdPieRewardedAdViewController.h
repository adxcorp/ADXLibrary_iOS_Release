//
//  AdPieRewardedAdViewController.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import "AdPieVideoAdData.h"

NS_ASSUME_NONNULL_BEGIN

@class AdPieVideoAdData;

@protocol AdPieRewardedAdViewControllerDelegate;

@interface AdPieRewardedAdViewController : UIViewController

@property (weak, nullable) id<AdPieRewardedAdViewControllerDelegate> delegate;
//@property AdPieAdContentType adType;

//- (instancetype)initWithAdType:(AdPieAdContentType)adType;
//- (instancetype)init NS_UNAVAILABLE;
//+ (instancetype)new NS_UNAVAILABLE;

- (BOOL)loadAdWithData:(AdPieVideoAdData *)adData;
- (void)show;

@end

@protocol AdPieRewardedAdViewControllerDelegate <NSObject>

@optional
- (void)rewardedAdDidLoad;
- (void)rewardedAdDidFailToLoadWithError:(NSError *)error;
- (void)rewardedAdWillPresentScreen;
- (void)rewardedAdWillDismissScreen;
- (void)rewardedAdDidDismissScreen;
- (void)rewardedAdDidEarnReward;
- (void)rewardedAdDidClick;

@end

NS_ASSUME_NONNULL_END
