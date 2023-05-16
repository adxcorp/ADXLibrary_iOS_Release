//
//  ADXLog.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADXLogLevel.h"

#define ADXLogTag(level)                      [[ADXLog sharedInstance] tagWithLogLevel:level className:NSStringFromClass([self class]) function:__PRETTY_FUNCTION__ line:__LINE__]

#define ADXLogWithLevel(level, fmt, ...)      [[ADXLog sharedInstance] logWithLevel:level tag:ADXLogTag(level) format:fmt, ## __VA_ARGS__]
#define ADXLogError(fmt, ...)                 ADXLogWithLevel(ADXLogLevelError, fmt, ##__VA_ARGS__)
#define ADXLogWarning(fmt, ...)               ADXLogWithLevel(ADXLogLevelWarning, fmt, ##__VA_ARGS__)
#define ADXLogInfo(fmt, ...)                  ADXLogWithLevel(ADXLogLevelInfo, fmt, ##__VA_ARGS__)
#define ADXLogDebug(fmt, ...)                 ADXLogWithLevel(ADXLogLevelDebug, fmt, ##__VA_ARGS__)

// debuggable = true
#define ADXDebugLogWithLevel(level, fmt, ...) if ([ADXLog sharedInstance].isDebuggable) { ADXLogWithLevel(level, fmt, ##__VA_ARGS__); }
#define ADXDebugLogError(fmt, ...)            ADXDebugLogWithLevel(ADXLogLevelError, fmt, ##__VA_ARGS__)
#define ADXDebugLog(fmt, ...)                 ADXDebugLogWithLevel(ADXLogLevelDebug, fmt, ##__VA_ARGS__)

NS_ASSUME_NONNULL_BEGIN

@interface ADXLog : NSObject

@property (assign) ADXLogLevel logLevel;
@property (nonatomic, assign, getter=isDebuggable) BOOL debuggable;

+ (instancetype)sharedInstance;

- (NSString *)tagWithLogLevel:(ADXLogLevel)logLevel className:(NSString *)className function:(const char *)function line:(int)line;

- (void)log:(NSString *)format, ...;
- (void)logWithLevel:(ADXLogLevel)logLevel tag:(NSString *)tag format:(NSString *)format, ...;

@end

NS_ASSUME_NONNULL_END
