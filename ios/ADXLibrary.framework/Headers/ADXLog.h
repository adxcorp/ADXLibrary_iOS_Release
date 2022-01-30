//
//  ADXLog.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADXLogLevel.h"

#define ADXLogTag(level)                 [[ADXLog sharedInstance] tagWithLogLevel:level className:NSStringFromClass([self class]) function:__PRETTY_FUNCTION__ line:__LINE__]

#define ADXLogWithLevel(level, fmt, ...) [[ADXLog sharedInstance] logWithLevel:level tag:ADXLogTag(level) format:fmt, ## __VA_ARGS__]
#define ADXLogWithError(err)             ADXLogWithLevel(ADXLogLevelError, @"ERROR: %@", err)
#define ADXLogError(fmt, ...)            ADXLogWithLevel(ADXLogLevelError, fmt, ##__VA_ARGS__)
#define ADXLogWarning(fmt, ...)          ADXLogWithLevel(ADXLogLevelWarning, fmt, ##__VA_ARGS__)
#define ADXLogInfo(fmt, ...)             ADXLogWithLevel(ADXLogLevelInfo, fmt, ##__VA_ARGS__)
#define ADXLogDebug(fmt, ...)            ADXLogWithLevel(ADXLogLevelDebug, fmt, ##__VA_ARGS__)

// debuggable = true 일때만 출력되는 로그
#define ADXDebugLogWithLevel(level, fmt, ...) if ([ADXLog sharedInstance].isDebuggable) { ADXLogWithLevel(level, fmt, ##__VA_ARGS__); }
#define ADXDebugLogWithError(err)             ADXDebugLogWithLevel(ADXLogLevelError, @"ERROR: %@", err)
#define ADXDebugLogError(fmt, ...)            ADXDebugLogWithLevel(ADXLogLevelError, fmt, ##__VA_ARGS__)
#define ADXDebugLogWarning(fmt, ...)          ADXDebugLogWithLevel(ADXLogLevelWarning, fmt, ##__VA_ARGS__)
#define ADXDebugLogInfo(fmt, ...)             ADXDebugLogWithLevel(ADXLogLevelInfo, fmt, ##__VA_ARGS__)
#define ADXDebugLogDebug(fmt, ...)            ADXDebugLogWithLevel(ADXLogLevelDebug, fmt, ##__VA_ARGS__)

NS_ASSUME_NONNULL_BEGIN

@interface ADXLog : NSObject

@property (nonatomic, assign) ADXLogLevel logLevel;
@property (nonatomic, assign, getter=isDebuggable) BOOL debuggable;

+ (instancetype)sharedInstance;

- (NSString *)tagWithLogLevel:(ADXLogLevel)logLevel className:(NSString *)className function:(const char *)function line:(int)line;

- (void)log:(NSString *)format, ...;
- (void)logWithLevel:(ADXLogLevel)logLevel tag:(NSString *)tag format:(NSString *)format, ...;

@end

NS_ASSUME_NONNULL_END
