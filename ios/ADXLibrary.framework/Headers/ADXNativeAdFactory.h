//
//  ADXNativeAdFactory.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ADXNativeAd.h"
#import "ADXTableViewAdPlacer.h"
#import "ADXCollectionViewAdPlacer.h"
#import "ADXAdPositioning.h"

@protocol ADXNativeAdFactoryDelegate <NSObject>

- (void)onSuccess:(NSString *)adUnitId nativeAd:(ADXNativeAd *)nativeAd;
- (void)onFailure:(NSString *)adUnitId;

@end

@interface ADXNativeAdFactory : NSObject

+ (ADXNativeAdFactory *)sharedInstance;

- (void)addDelegate:(id<ADXNativeAdFactoryDelegate>)delegate;
- (void)removeDelegate:(id<ADXNativeAdFactoryDelegate>)delegate;

- (void)preloadAd:(NSString *)adUnitId;
- (void)loadAd:(NSString *)adUnitId;

- (ADXNativeAd *)getNativeAd:(NSString *)adUnitId;

- (ADXTableViewAdPlacer *)getTableViewAdPlacer:(NSString *)adUnitId tableView:(UITableView *)tableView viewController:(UIViewController *)viewController adPositioning:(ADXAdPositioning *)adPositioning;

- (ADXCollectionViewAdPlacer *)getCollectionViewAdPlacer:(NSString *)adUnitId collectionView:(UICollectionView *)collectionView viewController:(UIViewController *)viewController adPositioning:(ADXAdPositioning *)adPositioning;

- (void)setRenderingViewClass:(NSString *)adUnitId renderingViewClass:(Class)renderingViewClass;
- (Class)getRenderingViewClass:(NSString *)adUnitId;

- (UIView *)getNativeAdView:(NSString *)adUnitId;

@end
