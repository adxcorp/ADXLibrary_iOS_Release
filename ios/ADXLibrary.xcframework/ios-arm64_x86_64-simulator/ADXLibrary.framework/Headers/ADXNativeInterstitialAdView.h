//
//  ADXNativeInterstitialAdView.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <ADXLibrary/ADXNativeAdRendering.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADXNativeInterstitialAdView : UIView <ADXNativeAdRendering>

@property (strong) UILabel *titleLabel;
@property (strong) UILabel *mainTextLabel;
@property (strong) UIButton *callToActionButton;
@property (strong) UIImageView *iconImageView;
@property (strong) UIImageView *mainImageView;
@property (strong) UILabel *adLabel;
@property (strong) UIImageView *privacyInformationIconImageView;

@end

NS_ASSUME_NONNULL_END
