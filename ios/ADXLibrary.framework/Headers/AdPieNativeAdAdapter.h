//
//  AdPieNativeAdAdapter.h
//  ADXLibrary
//
//  Created by 최치웅 on 12/08/2019.
//

#import <Foundation/Foundation.h>

#if __has_include(<MoPubSDK/MoPubSDK-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <MoPubSDK/MoPubSDK-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "MoPubSDK-Swift.h"
#endif

#import "MPNativeAdAdapter.h"
#import "MPAdDestinationDisplayAgent.h"

@class APNativeAd;

@interface AdPieNativeAdAdapter : NSObject <MPNativeAdAdapter, MPAdDestinationDisplayAgentDelegate>

@property (nonatomic, weak) id<MPNativeAdAdapterDelegate> delegate;

@property (nonatomic, strong) APNativeAd * nativeAd;
@property (nonatomic, strong) NSDictionary * properties;
@property (nonatomic, strong) MPAdImpressionTimer *impressionTimer;
@property (nonatomic, strong) id<MPAdDestinationDisplayAgent> destinationDisplayAgent;

- (instancetype)initWithNativeAd:(APNativeAd *)nativeAd;

@end
