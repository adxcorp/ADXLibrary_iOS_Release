//
//  ADXTableViewAdPlacer.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ADXAdPositioning.h"
#import "ADXTableViewAdPlacerDelegate.h"

@interface ADXTableViewAdPlacer : NSObject <ADXAdPlacer>

@property (nonatomic, weak) id<ADXTableViewAdPlacerDelegate> delegate;

+ (instancetype)placerWithTableView:(UITableView *)tableView viewController:(UIViewController *)controller viewSizeHandler:(ADXNativeViewSizeHandler)viewSizeHandler adPositioning:(ADXAdPositioning *)positioning renderingClass:(Class)renderingClass;

+ (instancetype)placerWithTableView:(UITableView *)tableView viewController:(UIViewController *)controller adPositioning:(ADXAdPositioning *)positioning renderingClass:(Class)renderingClass;

- (void)loadAdsForAdUnitID:(NSString *)adUnitID;

@end

@interface UITableView (ADXTableViewAdPlacer)

- (void)adx_setAdPlacer:(ADXTableViewAdPlacer *)placer;

- (ADXTableViewAdPlacer *)adx_adPlacer;

- (void)adx_setDataSource:(id<UITableViewDataSource>)dataSource;

- (id<UITableViewDataSource>)adx_dataSource;

- (void)adx_setDelegate:(id<UITableViewDelegate>)delegate;

- (id<UITableViewDelegate>)adx_delegate;

- (void)adx_beginUpdates;

- (void)adx_endUpdates;

- (void)adx_reloadData;

- (void)adx_insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;

- (void)adx_deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;

- (void)adx_reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;

- (void)adx_moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

- (void)adx_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;

- (void)adx_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;

- (void)adx_reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;

- (void)adx_moveSection:(NSInteger)section toSection:(NSInteger)newSection;

- (UITableViewCell *)adx_cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (id)adx_dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;

- (void)adx_deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

- (NSIndexPath *)adx_indexPathForCell:(UITableViewCell *)cell;

- (NSIndexPath *)adx_indexPathForRowAtPoint:(CGPoint)point;

- (NSIndexPath *)adx_indexPathForSelectedRow;

- (NSArray *)adx_indexPathsForRowsInRect:(CGRect)rect;

- (NSArray *)adx_indexPathsForSelectedRows;

- (NSArray *)adx_indexPathsForVisibleRows;

- (CGRect)adx_rectForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)adx_scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;

- (void)adx_selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition;

- (NSArray *)adx_visibleCells;

@end
