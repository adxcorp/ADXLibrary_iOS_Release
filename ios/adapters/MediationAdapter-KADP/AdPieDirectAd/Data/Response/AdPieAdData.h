//
//  AdPieAdData.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ADXLibrary/ADXObject.h>
#import "AdPieAdConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdPieAdData : ADXObject

@property (readonly, assign) AdPieAdContentType icType;
@property (readonly, assign) AdPieAdOrientation orientation;
@property (readonly, copy) NSString *adm; // 필수
@property (readonly, copy) NSString *admImageTag;
@property (readonly, assign) int width;
@property (readonly, assign) int height;
@property (readonly, copy) NSString *bgColor;
@property (readonly, assign) int position;
@property (readonly, assign) int animationType;
@property (readonly, assign) BOOL isScalable;
@property (readonly, assign) int monitoring;
@property (readonly, assign) BOOL webViewLanding;
@property (strong) NSArray *trackImpressionURLs;
@property (strong) NSArray *trackClickURLs;

@property (readonly, assign) BOOL webviewLoadingSkip; // wvls
@property (readonly, assign) int closeButtonPostion; // xposition
@property (readonly, assign) long closeButtonDelay; // cbd

@end

NS_ASSUME_NONNULL_END
