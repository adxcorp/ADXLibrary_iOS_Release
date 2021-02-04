//
//  NativeAdFactory.h
//  Pods
//
//  Created by 최치웅 on 2017. 3. 17..
//
//

@class MPNativeAd;
@class MPTableViewAdPlacer;
@class MPCollectionViewAdPlacer;
@class MPAdPositioning;

typedef CGSize (^MPNativeViewSizeHandler)(CGFloat maximumWidth);

@protocol NativeAdFactoryDelegate <NSObject>

- (void)onSuccess:(NSString *)adUnitId nativeAd:(MPNativeAd *)nativeAd;
- (void)onFailure:(NSString *)adUnitId;

@end


@interface NativeAdFactory : NSObject

@property (nonatomic, strong) NSMutableDictionary *nativeAds;
@property (nonatomic, strong) NSMutableDictionary *renderingViewClasses;
@property (nonatomic, strong) NSMutableDictionary *viewSizeHandlers;

@property (nonatomic, strong) NSMutableDictionary *loadings;
@property (nonatomic, strong) NSMutableDictionary *preloadings;

@property (nonatomic, strong) NSMutableSet *delegateSet;

+ (NativeAdFactory *)sharedInstance;

- (void)addDelegate:(id<NativeAdFactoryDelegate>)delegate;
- (void)removeDelegate:(id<NativeAdFactoryDelegate>)delegate;

- (void)preloadAd:(NSString *)adUnitId;
- (void)loadAd:(NSString *)adUnitId;

- (MPTableViewAdPlacer *)getTableViewAdPlacer:(NSString *)adUnitId tableView:(UITableView *)tableView viewController:(UIViewController *)viewController viewSizeHandler:(MPNativeViewSizeHandler)viewSizeHandler;
- (MPTableViewAdPlacer *)getTableViewAdPlacer:(NSString *)adUnitId tableView:(UITableView *)tableView viewController:(UIViewController *)viewController viewSizeHandler:(MPNativeViewSizeHandler)viewSizeHandler adPositioning:(MPAdPositioning *)adPositioning;

- (MPCollectionViewAdPlacer *)getCollectionViewAdPlacer:(NSString *)adUnitId collectionView:(UICollectionView *)collectionView viewController:(UIViewController *)viewController viewSizeHandler:(MPNativeViewSizeHandler)viewSizeHandler;
- (MPCollectionViewAdPlacer *)getCollectionViewAdPlacer:(NSString *)adUnitId collectionView:(UICollectionView *)collectionView viewController:(UIViewController *)viewController viewSizeHandler:(MPNativeViewSizeHandler)viewSizeHandler adPositioning:(MPAdPositioning *)adPositioning;

- (MPNativeAd *)getNativeAd:(NSString *)adUnitId;

- (void)setRenderingViewClass:(NSString *)adUnitId renderingViewClass:(Class)renderingViewClass;
- (Class)getRenderingViewClass:(NSString *)adUnitId;

- (UIView *)getNativeAdView:(NSString *)adUnitId;

@end
