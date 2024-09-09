//
//  ADXNativeAd.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ADXAdConstants.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ADXNativeAdDelegate;

@interface ADXNativeAd : NSObject

@property (copy, readonly) NSString *adUnitId;
@property (weak, nullable) id<ADXNativeAdDelegate> delegate;
@property (strong) NSDate *creationDate;
@property (nonatomic, copy, nullable) ADXPaidEventHandler paidEventHandler;

- (instancetype)initWithAdUnitId:(NSString *)adUnitId withRenderingClass:(Class)renderingClass NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)decoder NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (void)loadAd;
- (nullable UIView *)retrieveAdViewWithError:(NSError **)error;

// for internal only
- (UIView *)retrieveAdViewForSizeCalculationWithError:(NSError **)error;
- (void)updateAdViewSize:(CGSize)size;

@end

@protocol ADXNativeAdDelegate <NSObject>

- (UIViewController *)viewControllerForPresentingModalView;

@optional
- (void)nativeAdDidLoad:(ADXNativeAd *)nativeAd;
- (void)nativeAd:(ADXNativeAd *)nativeAd didFailToLoadWithError:(NSError *)error;
- (void)nativeAdDidClick:(ADXNativeAd *)nativeAd;
- (void)nativeAdTrackImpression:(ADXNativeAd *)nativeAd;
@end

NS_ASSUME_NONNULL_END
