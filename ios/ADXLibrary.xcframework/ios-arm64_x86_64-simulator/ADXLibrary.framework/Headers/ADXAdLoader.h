//
//  ADXAdLoader.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ADXLibrary/ADXAdResponse.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ADXAdLoadDelegate;

@interface ADXAdLoader : NSObject

@property (copy, readonly) NSString *adUnitId;
@property (weak, nullable) id<ADXAdLoadDelegate> delegate;

@property (assign, readonly, getter=isLoading) BOOL loading;

- (instancetype)initWithAdUnitId:(NSString *)adUnitId;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (void)setSSVOptionWithUserId:(NSString *_Nullable)userId customData:(NSString *_Nullable)customData;
- (void)loadBannerAd;
- (void)loadInterstitialAd;
- (void)loadNativeAd;
- (void)loadRewardedAd;

- (void)cancel;

+ (NSString *)getTargetDomainForLite:(NSString *)originalString
                     stringToReplace:(NSString *)stringToReplace
                          liteDomain:(NSString *)liteDomain
                       defaultDomain:(NSString *)defaultDomain;

@end

@protocol ADXAdLoadDelegate <NSObject>

- (void)adLoader:(ADXAdLoader *)loader didReceiveAdResponse:(ADXAdResponse *)adResponse;
- (void)adLoader:(ADXAdLoader *)loader didFailToReceiveAdWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
