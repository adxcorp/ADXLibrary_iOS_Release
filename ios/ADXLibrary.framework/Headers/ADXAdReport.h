//
//  ADXAdReport.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADXAdConstants.h"
#import "ADXMediationData.h"
#import "ADXLog.h"

#define ADXLogEvent(network, type, event)             ADXLogInfo(@"[%@-%@] %@", network, type, event)
#define ADXLogEventError(network, type, event, error) ADXLogError(@"[%@-%@] %@: %@", network, type, event, error)

#define ADXMetric(mediation, adEvent)                 [ADXAdReport sendMetricWithTag:ADXLogTag(ADXLogLevelInfo) mediationData:mediation event:adEvent message:nil]
#define ADXMetricError(mediation, adEvent, error)     [ADXAdReport sendMetricWithTag:ADXLogTag(ADXLogLevelError) mediationData:mediation event:adEvent message:[NSString stringWithFormat:@"%@", error]]

NS_ASSUME_NONNULL_BEGIN

@interface ADXAdReport : NSObject

+ (void)sendMetricWithTag:(NSString *)tag mediationData:(ADXMediationData *)mediation event:(ADXAdEvent)event message:(nullable NSString *)message;

@end

NS_ASSUME_NONNULL_END



