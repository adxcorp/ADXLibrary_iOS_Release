//
//  AdPieEndCardData.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdPieEndCardData : NSObject

@property (assign) NSInteger width;
@property (assign) NSInteger height;
@property (strong) NSString * staticResource;
@property (strong) NSString * htmlResource;
@property (strong) NSString * iframeResource;
@property (strong) NSString * clickThrough;
@property (strong) NSArray<NSString *> * clickTracking;
@property (strong) NSArray<NSString *> * creativeView;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
