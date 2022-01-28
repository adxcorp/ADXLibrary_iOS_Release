//
//  ADXReward.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const ADXRewardCurrencyType;
extern NSInteger const ADXRewardCurrencyAmount;

@interface ADXReward : NSObject

@property (nonatomic, readonly) NSString *currencyType;
@property (nonatomic, readonly) NSNumber *amount;

- (instancetype)initWithCurrencyAmount:(NSNumber *)amount;
- (instancetype)initWithCurrencyType:(NSString *)currencyType amount:(NSNumber *)amount;

+ (instancetype)unspecifiedReward;

@end

NS_ASSUME_NONNULL_END
