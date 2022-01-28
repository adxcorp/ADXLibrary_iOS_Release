//
//  NativeAdFactory.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

@class ADXNativeAd;

@protocol NativeAdFactoryDelegate <NSObject>

- (void)onSuccess:(NSString *)adUnitId nativeAd:(ADXNativeAd *)nativeAd;
- (void)onFailure:(NSString *)adUnitId;

@end

@interface NativeAdFactory : NSObject

+ (NativeAdFactory *)sharedInstance;

- (void)addDelegate:(id<NativeAdFactoryDelegate>)delegate;
- (void)removeDelegate:(id<NativeAdFactoryDelegate>)delegate;

- (void)preloadAd:(NSString *)adUnitId;
- (void)loadAd:(NSString *)adUnitId;

- (ADXNativeAd *)getNativeAd:(NSString *)adUnitId;

- (void)setRenderingViewClass:(NSString *)adUnitId renderingViewClass:(Class)renderingViewClass;
- (Class)getRenderingViewClass:(NSString *)adUnitId;

- (UIView *)getNativeAdView:(NSString *)adUnitId;

@end
