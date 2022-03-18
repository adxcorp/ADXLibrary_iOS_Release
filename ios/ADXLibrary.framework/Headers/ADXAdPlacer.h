//
//  ADXAdPlacer.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADXNativeAd.h"

NS_ASSUME_NONNULL_BEGIN

typedef CGSize (^ADXNativeViewSizeHandler)(CGFloat maximumWidth);

@protocol ADXAdPlacerDelegate;

@protocol ADXAdPlacer <NSObject>

@required

@property (nonatomic, weak, nullable) id<ADXAdPlacerDelegate> delegate;

@end

@protocol ADXAdPlacerDelegate <NSObject>

@optional

- (void)adxAdPlacer:(id<ADXAdPlacer>)adPlacer didTrackImpressionForAd:(ADXNativeAd *)ad;

@end

NS_ASSUME_NONNULL_END
