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
@property (nonatomic, assign, readonly, getter=isLoaded) BOOL loaded;
@property (nonatomic, readonly) NSDictionary *properties;

- (instancetype)initWithAdUnitId:(NSString *)adUnitId withRenderingClass:(Class)renderingClass;
- (void)loadAd;

- (nullable UIView *)retrieveAdViewWithError:(NSError **)error;

@end

@protocol ADXNativeAdDelegate <NSObject>

- (void)nativeAdDidLoad:(ADXNativeAd *)nativeAd;
- (void)nativeAd:(ADXNativeAd *)nativeAd didFailWithError:(NSError *)error;

- (UIViewController *)viewControllerForPresentingModalView;

@optional
- (void)nativeAdDidClick:(ADXNativeAd *)nativeAd;

@end

NS_ASSUME_NONNULL_END
