//
//  ADXAdLogEvent.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADXAdConstants.h"
#import "ADXLog.h"

#define ADXLogEvent(network, type, event)              ADXLogDebug(@"[%@Adapter] %@ %@", network, type, event)
#define ADXLogEventError(network, type, event, error)  ADXLogError(@"[%@Adapter] %@ %@: %@", network, type, event, error)
