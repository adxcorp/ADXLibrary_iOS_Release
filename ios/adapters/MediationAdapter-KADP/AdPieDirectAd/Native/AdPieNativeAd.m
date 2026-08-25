//
//  AdPieNativeAd.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "AdPieNativeAd.h"

#import "AdPieNativeAdData.h"

#import <ADXLibrary/ADXAdError.h>
#import <ADXLibrary/ADXAdLogEvent.h>
#import <ADXLibrary/ADXHTTPNetworkSession.h>

@interface AdPieNativeAd ()

@property (assign, getter=isReportedImpression) BOOL reportedImpression;

@end

@implementation AdPieNativeAd

- (void)loadWithAdData:(AdPieNativeAdData *)adData {
    _adData = adData;
    
    if (adData == nil) {
        if ([self.delegate respondsToSelector:@selector(nativeAd:didFailToLoadWithError:)]) {
            [self.delegate nativeAd:self didFailToLoadWithError:[NSError errorWithCode:ADXAdErrorInvalidRequest]];
        }
        
        return;
    }
    
    ADXDebugLog(@"loadWithAdData: %@", adData.dictionary);
    
    if ([self.delegate respondsToSelector:@selector(nativeAdDidLoad:)]) {
        [self.delegate nativeAdDidLoad:self];
    }
}

- (void)fireImpression {
    ADXDebugLog(@"fireImpression");
    
    if (self.adData && self.adData.trackImpressionURLs) {
        // impression 중복 호출되지 않도록 플래그 추가
        if (!self.isReportedImpression) {
            self.reportedImpression = YES;
            
            ADXDebugLog(@"trackImpressionURLs: %@", self.adData.trackImpressionURLs);
            
            for (NSString *string in self.adData.trackImpressionURLs) {
                [ADXHTTPNetworkSession GETStartTaskWithRequestURLString:string];
            }
            
            if ([self.delegate respondsToSelector:@selector(nativeAdTrackImpression:)]) {
                [self.delegate nativeAdTrackImpression:self];
            }
        }
    }
}

- (void)invokeDefaultAction {
    ADXDebugLog(@"invokeDefaultAction");
    
    if (self.adData && self.adData.trackClickURLs) {
        // 클릭처리
        ADXDebugLog(@"trackClickURLs: %@", self.adData.trackClickURLs);
        
        for (NSString *string in self.adData.trackClickURLs) {
            [ADXHTTPNetworkSession GETStartTaskWithRequestURLString:string];
        }
    }
    
    NSURL *url = [NSURL URLWithString:self.adData.link];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    
    if ([self.delegate respondsToSelector:@selector(nativeAdDidClick:)]) {
        [self.delegate nativeAdDidClick:self];
    }
}

- (void)invokePrivacyIconAction {
    ADXDebugLog(@"invokePrivacyIconAction");
    
    if (self.adData && self.adData.optoutLink) {
        ADXLogDebug(@"privacy URL: %@", self.adData.optoutLink);
        
        NSURL *url = [NSURL URLWithString:self.adData.optoutLink];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

@end
