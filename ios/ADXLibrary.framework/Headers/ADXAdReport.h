//
//  ADXAdReport.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADXAdConstants.h"
#import "ADXMediationData.h"
#import "ADXLogger.h"

#define ADXLogEvent(network, type, event) ADXLogInfo(@"[%@-%@] %@", network, type, event)
#define ADXLogEventError(network, type, event, errorMsg) ADXLogError(@"[%@-%@] %@: %@", network, type, event, errorMsg)

NS_ASSUME_NONNULL_BEGIN

@interface ADXAdReport : NSObject

@end

NS_ASSUME_NONNULL_END



