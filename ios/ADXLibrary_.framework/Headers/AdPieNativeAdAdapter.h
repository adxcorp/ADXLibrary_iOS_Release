//
//  AdPieNativeAdAdapter.h
//  ADXLibrary
//
//  Created by 최치웅 on 12/08/2019.
//

#import <Foundation/Foundation.h>

#import "MPNativeAdAdapter.h"
#import "MPAdImpressionTimer.h"
#import "MPAdDestinationDisplayAgent.h"

@class APNativeAd;

@interface AdPieNativeAdAdapter : NSObject <MPNativeAdAdapter, MPAdImpressionTimerDelegate, MPAdDestinationDisplayAgentDelegate>

@property(nonatomic, weak) id<MPNativeAdAdapterDelegate> delegate;

@property (nonatomic, strong) APNativeAd * nativeAd;
@property (nonatomic, strong) NSDictionary * properties;
@property (nonatomic, strong) MPAdImpressionTimer *impressionTimer;
@property (nonatomic, strong) MPAdDestinationDisplayAgent *destinationDisplayAgent;

- (instancetype)initWithNativeAd:(APNativeAd *)nativeAd;

@end
