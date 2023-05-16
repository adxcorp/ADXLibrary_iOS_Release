//
//  ADXObject.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADXObject : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionary;

- (nullable id)objectForKey:(NSString *)key;
- (nullable NSMutableDictionary *)mutableDictionaryForKey:(NSString *)key;
- (nullable NSDictionary *)dictionaryForKey:(NSString *)key;
- (nullable NSMutableArray *)mutableArrayForKey:(NSString *)key;
- (nullable NSArray *)arrayForKey:(NSString *)key;
- (nullable NSURL *)urlForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;
- (int)intForKey:(NSString *)key;
- (long)longForKey:(NSString *)key;
- (double)dobuleForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
