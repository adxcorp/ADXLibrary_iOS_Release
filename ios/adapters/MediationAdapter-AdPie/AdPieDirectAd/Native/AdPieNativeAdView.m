//
//  AdPieNativeAdView.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "AdPieNativeAdView.h"

#import <AdPieSDK/AdPieSDK.h>
#import "AdPieNativeAd.h"

@implementation AdPieNativeAdView

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    
    if (self.nativeAd != nil && newWindow != nil) {
        if ([self.delegate respondsToSelector:@selector(nativeAdViewTrackImpression:)]) {
            [self.delegate nativeAdViewTrackImpression:self];
        }
    }
}

- (void)registerClickableViews:(NSArray<UIView *> *)clickableViews {
    for (UIView *clickableView in clickableViews) {
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickNativeAd:)];
        
        [clickableView addGestureRecognizer:singleFingerTap];
        clickableView.userInteractionEnabled = YES;
    }
}

- (void)registerClickablePrivacy:(UIView *)clickableView {
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickNativePrivacy:)];
    
    [clickableView addGestureRecognizer:singleFingerTap];
    clickableView.userInteractionEnabled = YES;
}

- (void)clickNativeAd:(UITapGestureRecognizer *)recognizer {
    if ([self.delegate respondsToSelector:@selector(nativeAdViewDidClick:)]) {
        [self.delegate nativeAdViewDidClick:self];
    }
}

- (void)clickNativePrivacy:(UITapGestureRecognizer *)recognizer {
    if (self.nativeAd != nil) {
        if ([self.nativeAd isKindOfClass:[AdPieNativeAd class]]) {
            [(AdPieNativeAd *)self.nativeAd invokePrivacyIconAction];
            
        } else if ([self.nativeAd isKindOfClass:[APNativeAd class]]) {
            NSString *optoutLink = ((APNativeAd *)self.nativeAd).nativeAdData.optoutLink;
            
            if (optoutLink != nil && optoutLink.length > 0) {
                [[AdPieSDK sharedInstance] openURLwithString:optoutLink];
            }
        }
    }
}

@end
