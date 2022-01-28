//
//  ADXLog.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADXLogger.h"

// debuggable = true 일때만 출력되는 로그
#define ADXDebugLogWithLevel(level, fmt, ...) if ([[ADXLog sharedInstance] isDebuggable]) { ADXLogWithLevel(level, fmt, ##__VA_ARGS__); }
#define ADXDebugLogWithError(err) ADXDebugLogWithLevel(ADXLogLevelError, @"ERROR: %@", err)
#define ADXDebugLogError(fmt, ...) ADXDebugLogWithLevel(ADXLogLevelError, fmt, ##__VA_ARGS__)
#define ADXDebugLogWarning(fmt, ...) ADXDebugLogWithLevel(ADXLogLevelWarning, fmt, ##__VA_ARGS__)
#define ADXDebugLogInfo(fmt, ...) ADXDebugLogWithLevel(ADXLogLevelInfo, fmt, ##__VA_ARGS__)
#define ADXDebugLogDebug(fmt, ...) ADXDebugLogWithLevel(ADXLogLevelDebug, fmt, ##__VA_ARGS__)

NS_ASSUME_NONNULL_BEGIN

@interface ADXLog : NSObject

@property (nonatomic, assign, getter=isDebuggable) BOOL debuggable;

+ (instancetype)sharedInstance;

- (void)log:(NSString *)message;
- (void)logWithLevel:(ADXLogLevel)logLevel className:(NSString *)className function:(const char *)function line:(int)line message:(NSString *)message;
- (void)logWithLevel:(ADXLogLevel)logLevel className:(NSString *)className line:(int)line message:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
