//
//  ADXLogger.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADXLogLevel.h"

#define ADXLogWithLevel(level, fmt, ...) [[ADXLogger sharedInstance] logWithLevel:level className:NSStringFromClass([self class]) function:__PRETTY_FUNCTION__ line:__LINE__ format:fmt, ## __VA_ARGS__]

#define ADXLogWithError(err) ADXLogWithLevel(ADXLogLevelError, @"ERROR: %@", err)
#define ADXLogError(fmt, ...) ADXLogWithLevel(ADXLogLevelError, fmt, ##__VA_ARGS__)
#define ADXLogWarning(fmt, ...) ADXLogWithLevel(ADXLogLevelWarning, fmt, ##__VA_ARGS__)
#define ADXLogInfo(fmt, ...) ADXLogWithLevel(ADXLogLevelInfo, fmt, ##__VA_ARGS__)
#define ADXLogDebug(fmt, ...) ADXLogWithLevel(ADXLogLevelDebug, fmt, ##__VA_ARGS__)
#define ADXOSLog(fmt, ...) [[ADXLogger sharedInstance] log:fmt, ##__VA_ARGS__]

NS_ASSUME_NONNULL_BEGIN

@interface ADXLogger : NSObject

@property (nonatomic, assign) ADXLogLevel logLevel;

+ (instancetype)sharedInstance;

- (void)log:(NSString *)format, ...;
- (void)logWithLevel:(ADXLogLevel)logLevel className:(NSString *)className function:(const char *)function line:(int)line format:(NSString *)format, ...;

@end

NS_ASSUME_NONNULL_END
