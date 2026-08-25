//
//  ADXAdPieNativeAd.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ADXLibrary/ADXMediationAd.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADXAdPieNativeAd : NSObject <ADXMediationNativeAd>
- (double)getPrice;
@end

NS_ASSUME_NONNULL_END
