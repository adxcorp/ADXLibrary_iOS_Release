//
//  ADXNativeAd.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ADXNativeAdDelegate;

@interface ADXNativeAd : NSObject

@property (nonatomic, copy, readonly) NSString *adUnitId;
@property (nonatomic, weak, nullable) id<ADXNativeAdDelegate> delegate;
@property (nonatomic, strong) NSDate *creationDate;

- (instancetype)initWithAdUnitId:(NSString *)adUnitId withRenderingClass:(Class)renderingClass;
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
- (void)nativeAd:(ADXNativeAd *)nativeAd didFailWithError:(NSError *)error;
- (void)nativeAdDidClick:(ADXNativeAd *)nativeAd;
- (void)trackImpression:(ADXNativeAd *)nativeAd;
@end

NS_ASSUME_NONNULL_END
