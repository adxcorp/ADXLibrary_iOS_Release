//
//  ADXAdPositioning.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADXAdPositioning : NSObject <NSCopying>

@property (nonatomic, assign) NSUInteger repeatingInterval;
@property (nonatomic, strong, readonly) NSMutableOrderedSet *fixedPositions;

+ (instancetype)positioning;

- (void)addFixedIndexPath:(NSIndexPath *)indexPath;
- (void)enableRepeatingPositionsWithInterval:(NSUInteger)interval;

@end
