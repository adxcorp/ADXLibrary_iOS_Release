//
//  UIColor+ADXHexString.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (ADXHexString)

+ (UIColor *)colorWithHexString:(NSString *)hexString;

@end

NS_ASSUME_NONNULL_END
