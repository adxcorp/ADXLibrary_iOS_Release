//
//  ADXAdView.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ADXAdConstants.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ADXAdViewDelegate;

@interface ADXAdView : UIView

@property (nonatomic, copy, nullable) IBInspectable NSString *adUnitId;
@property (nonatomic, weak, nullable) IBOutlet UIViewController *rootViewController;
@property (nonatomic, weak, nullable) IBOutlet id<ADXAdViewDelegate> delegate;
@property (nonatomic, assign) ADXAdSize adSize;

- (instancetype)initWithAdUnitId:(NSString *)adUnitId
                          adSize:(ADXAdSize)adSize
              rootViewController:(UIViewController *)rootViewController NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)decoder NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (void)loadAd;

- (void)startAutomaticallyRefreshingContents;
- (void)stopAutomaticallyRefreshingContents;

@end

@protocol ADXAdViewDelegate <NSObject>

- (void)adViewDidLoad:(ADXAdView *)adView;
- (void)adView:(ADXAdView *)adView didFailToLoadWithError:(NSError *)error;

@optional
- (void)adViewDidClick:(ADXAdView *)adView;

@end

NS_ASSUME_NONNULL_END
