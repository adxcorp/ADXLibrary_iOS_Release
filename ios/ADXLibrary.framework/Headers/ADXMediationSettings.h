//
//  ADXMediationSettings.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADXObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface ADXMediationSettings : ADXObject

@property (nonatomic, readonly, assign) long bannerRefreshInterval;
@property (nonatomic, readonly, assign) BOOL debuggable;

@end


NS_ASSUME_NONNULL_END
