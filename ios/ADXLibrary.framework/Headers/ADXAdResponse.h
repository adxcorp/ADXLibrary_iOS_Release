//
//  ADXAdResponse.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADXObject.h"
#import "ADXMediationData.h"
#import "ADXMediationSettings.h"

NS_ASSUME_NONNULL_BEGIN

@interface ADXAdResponse : ADXObject

@property (nonatomic, readonly, copy, nullable) NSArray<ADXMediationData *> *mediations;
@property (nonatomic, readonly, copy) ADXMediationSettings *settings;

@end

NS_ASSUME_NONNULL_END
