//
//  ADXCollectionViewAdPlacer.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ADXAdPositioning.h"
#import "ADXCollectionViewAdPlacerDelegate.h"

@interface ADXCollectionViewAdPlacer : NSObject <ADXAdPlacer>

@property (weak) id<ADXCollectionViewAdPlacerDelegate> delegate;

+ (instancetype)placerWithCollectionView:(UICollectionView *)collectionView
                          viewController:(UIViewController *)controller
                         viewSizeHandler:(ADXNativeViewSizeHandler)viewSizeHandler
                           adPositioning:(ADXAdPositioning *)positioning
                          renderingClass:(Class)renderingClass;

+ (instancetype)placerWithCollectionView:(UICollectionView *)collectionView
                          viewController:(UIViewController *)controller
                           adPositioning:(ADXAdPositioning *)positioning
                          renderingClass:(Class)renderingClass;

- (void)loadAdsForAdUnitID:(NSString *)adUnitID;

@end

@interface UICollectionView (ADXCollectionViewAdPlacer)

- (BOOL)adx_isValidIndexPath:(NSIndexPath *)indexPath;

- (void)adx_setAdPlacer:(ADXCollectionViewAdPlacer *)placer;

- (ADXCollectionViewAdPlacer *)adx_adPlacer;

- (void)adx_setDataSource:(id<UICollectionViewDataSource>)dataSource;

- (id<UICollectionViewDataSource>)adx_dataSource;

- (void)adx_setDelegate:(id<UICollectionViewDelegate>)delegate;

- (id<UICollectionViewDelegate>)adx_delegate;

- (void)adx_waitForCollectionViewUpdate:(void(^)(void))completionHandler;

- (void)adx_reloadData;

- (void)adx_insertItemsAtIndexPaths:(NSArray *)indexPaths;

- (void)adx_deleteItemsAtIndexPaths:(NSArray *)indexPaths;

- (void)adx_reloadItemsAtIndexPaths:(NSArray *)indexPaths;

- (void)adx_moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

- (void)adx_insertSections:(NSIndexSet *)sections;

- (void)adx_deleteSections:(NSIndexSet *)sections;

- (void)adx_reloadSections:(NSIndexSet *)sections;

- (void)adx_moveSection:(NSInteger)section toSection:(NSInteger)newSection;

- (UICollectionViewCell *)adx_cellForItemAtIndexPath:(NSIndexPath *)indexPath;

- (id)adx_dequeueReusableSupplementaryViewOfKind:(NSString *)elementKind withReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;

- (id)adx_dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath*)indexPath;

- (void)adx_deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

- (NSIndexPath *)adx_indexPathForCell:(UICollectionViewCell *)cell;

- (NSIndexPath *)adx_indexPathForItemAtPoint:(CGPoint)point;

- (NSArray *)adx_indexPathsForSelectedItems;

- (NSArray *)adx_indexPathsForVisibleItems;

- (UICollectionViewLayoutAttributes *)adx_layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)adx_scrollToItemAtIndexPath:(NSIndexPath *)indexPath
                   atScrollPosition:(UICollectionViewScrollPosition)scrollPosition
                           animated:(BOOL)animated;

- (void)adx_selectItemAtIndexPath:(NSIndexPath *)indexPath
                         animated:(BOOL)animated
                   scrollPosition:(UICollectionViewScrollPosition)scrollPosition;

- (NSArray *)adx_visibleCells;

@end
