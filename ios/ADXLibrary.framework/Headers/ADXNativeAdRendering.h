//
//  ADXNativeAdRendering.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

@protocol ADXNativeAdRendering <NSObject>

@optional

/**
 Return the UILabel that your view is using for the main text.

 @return a UILabel that is used for the main text.
 */
- (UILabel *)nativeMainTextLabel;

/**
 Return the UILabel that your view is using for the title text.

 @return a UILabel that is used for the title text.
 */
- (UILabel *)nativeTitleTextLabel;

/**
 Return the UIImageView that your view is using for the icon image.

 @return a UIImageView that is used for the icon image.
 */
- (UIImageView *)nativeIconImageView;

/**
 Return the UIImageView that your view is using for the main image.

 @return a UIImageView that is used for the main image.
 */
- (UIImageView *)nativeMainImageView;

/**
 Return the @c UILabel that your view is using for text indicating the
 sponsor that sponsored the ad.

 Sometimes sponsor information is not included with the advertisement; in that
 case, MoPub will set the label's @c text to empty string and the label's @c hidden
 property to @c YES. Please configure your view to be ready for this possibility.

 @return a @c UILabel to be used for "Sponsored by Example" text
 */
- (UILabel *)nativeSponsoredByCompanyTextLabel;

/**
 Specifies custom text for @c nativeSponsoredByCompanyTextLabel, primarily to be used
 for localization, but also can be used for custom copy, e.g., "Brought to you by Example"
 rather than the default "Sponsored by Example".

 If this method is not implemented, or is implemented to return @c nil or empty string, we
 will use the default "Sponsored by Example"

 @param sponsorName The name of the sponsor who sponored the native ad
 @return an assembled string containing @c sponsorName indicating something to the effect
 of "Sponsored by <sponsorName>"
 */
+ (NSString *)localizedSponsoredByTextWithSponsorName:(NSString *)sponsorName;

/**
 Returns the UIButton that your view is using for the call to action (cta) text.

 @return a UIButton that is used for the cta text.
 */
- (UIButton *)nativeCallToActionTextButton;

/**
 Returns the UIImageView that your view is using for the privacy information icon.

 @return a UIImageView that is used for the privacy information icon.
 */
- (UIImageView *)nativePrivacyInformationIconImageView;

/**
 Specifies a nib object containing a view that should be used to render ads.

 If you want to use a nib object to render ads, you must implement this method.

 @return an initialized UINib object. This is not allowed to be `nil`.
 */
+ (UINib *)nibForAd;

/**
 Return the array of @c UIView instances that may be clickable. If not implemented, the view's
 subviews will be used by default.

 In some cases, especially in view subclasses that have a complex view hierarchy, it may be
 desirable to specify a subset of views that are considered clickable. Supply these views here.

 @return an array of @c UIView instances.
 */
- (NSArray <UIView *> *)clickableViews;

@end
