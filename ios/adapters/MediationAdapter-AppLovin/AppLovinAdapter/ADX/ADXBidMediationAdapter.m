//
//  ADXBidMediationAdapter.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

// 참조 - Building a Custom Adapter
// https://developers.applovin.com/en/demand-partners/building-a-custom-adapter

#import "ADXBidMediationAdapter.h"
#import <ADXLibrary/ADXSdk.h>
#import <ADXLibrary/ADXRewardedAd.h>

typedef NS_ENUM(NSInteger, ADXBidCompareResult){
    ADX_BID_RESULT_MATCHED,
    ADX_BID_RESULT_LOW_PRICE,
    ADX_BID_RESULT_INSUFFICIENT_DATA,
    ADX_BID_RESULT_DISABLE_BIDDING,
    ADX_BID_RESULT_ZERO_PRICE,
    ADX_BID_RESULT_FORMAT_UNKNOWN,
};

@interface ADXBidMediationAdapter () <ADXMediationRewardedAdDelegate,
    ADXMediationInterstitialAdDelegate,
    ADXMediationBannerAdDelegate>

@property (weak) id<ADXMediationAd> loadedAd;
@property (weak) UIView * bannerView;

@property (weak) id<MARewardedAdapterDelegate> rewardedDelegate;
@property (weak) id<MAInterstitialAdapterDelegate> interstitialDelegate;
@property (weak) id<MAAdViewAdapterDelegate> bannerDelegate;

@end


@implementation ADXBidMediationAdapter

- (NSString *)SDKVersion {
    return ADX_SDK_VERSION;
}

- (NSString *)adapterVersion {
    return [NSString stringWithFormat:@"%@.0", ADX_SDK_VERSION];
}

- (void)destroy {
    // do nothing
}

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters
               completionHandler:(void (^)(MAAdapterInitializationStatus, NSString * _Nullable))completionHandler
{
    ADXDebugLog(@"initializeWithParameters:completionHandler:");
    if(completionHandler == nil) { return; }
    completionHandler(MAAdapterInitializationStatusDoesNotApply, nil);
}

#pragma mark - Compare Prices
- (ADXBidCompareResult)isHigherThanOrEqualToFloorPrice:(nonnull id<MAAdapterResponseParameters>)parameters
{
    NSDictionary<NSString *, id> * localParameters = [parameters localExtraParameters];
    NSDictionary<NSString *, id> * serverParameters = [parameters serverParameters];
    ADXDebugLog(@"placementIdentifier: %@", parameters.thirdPartyAdPlacementIdentifier);
    ADXDebugLog(@"localParameters: %@, ServerParameters: %@", localParameters, serverParameters);
    
    if (![localParameters isKindOfClass:[NSDictionary class]] || ![localParameters count] ||
        ![serverParameters isKindOfClass:[NSDictionary class]] || ![serverParameters count]) {
        return ADX_BID_RESULT_INSUFFICIENT_DATA;
    }
    
    NSDictionary * adxLocalData = [localParameters objectForKey:@"adx_local_data"];
    if (![adxLocalData isKindOfClass:[NSDictionary class]] || ![adxLocalData count]) {
        return ADX_BID_RESULT_INSUFFICIENT_DATA;
    }
    
    /// Check Ad format type
    ADXAdFormatType formatType = ADXADX_AD_FORMAT_UNKNOWN;
    id formatObj = [adxLocalData objectForKey:@"format"];
    if (formatObj == nil || ![formatObj respondsToSelector:@selector(integerValue)]) {
         return ADX_BID_RESULT_INSUFFICIENT_DATA;
    }
    formatType = [formatObj integerValue];
    
    if(formatType == ADXADX_AD_FORMAT_UNKNOWN) {
        return ADX_BID_RESULT_FORMAT_UNKNOWN;
    }
    
    if(formatType == ADX_AD_FORMAT_NATIVE) {
        if([adxLocalData objectForKey:@"is_native_ad_loaded"] == nil) {
            ADXDebugLog(@"No Ads loaded");
            return ADX_BID_RESULT_INSUFFICIENT_DATA;
        }
    } else {
        /// custom_event (object for rewarded, interstitial and banner)
        id customEvent = [adxLocalData objectForKey:@"custom_event"];
        if (customEvent == nil || [customEvent isKindOfClass:[NSNull class]]) {
            ADXDebugLog(@"No Ads loaded");
            return ADX_BID_RESULT_INSUFFICIENT_DATA;
        }
        self.loadedAd = customEvent;
    }
    
    if(formatType == ADX_AD_FORMAT_BANNER) {
        id bannerView = [adxLocalData objectForKey:@"custom_banner_view"];
        if(bannerView == nil || [bannerView isKindOfClass:[NSNull class]] || ![bannerView isKindOfClass:[UIView class]]) {
            ADXDebugLog(@"No BannerView");
            return ADX_BID_RESULT_INSUFFICIENT_DATA;
        }
        self.bannerView = bannerView;
    }
    
    /// Check keys and values for bidding option in data.
    id biddingValue = [adxLocalData objectForKey:@"enable_bidding"];
    if (biddingValue == nil || ![biddingValue respondsToSelector:@selector(integerValue)]) {
        return ADX_BID_RESULT_INSUFFICIENT_DATA;
    }
    BOOL isEnableBidding = [biddingValue integerValue] > 0;
    if(!isEnableBidding) {
        ADXDebugLog(@"DISABLE_BIDDING");
        return ADX_BID_RESULT_DISABLE_BIDDING;
    }
    
    /// FloorPrice (AppLovin DashBoard - Custom Networks - Custom Parameters)
    id customParametersObj = [serverParameters objectForKey:@"custom_parameters"];
    if (![customParametersObj isKindOfClass:[NSDictionary class]]) {
        ADXDebugLog(@"No Custom Parameters");
        return ADX_BID_RESULT_INSUFFICIENT_DATA;
    }
    NSDictionary<NSString *, id> * customParameters = customParametersObj;
    
    id floorPriceObj = [customParameters objectForKey:@"floor_price"];
    if (floorPriceObj == nil || ![floorPriceObj respondsToSelector:@selector(doubleValue)]) {
        return ADX_BID_RESULT_INSUFFICIENT_DATA;
    }
    if ([floorPriceObj isKindOfClass:[NSString class]] && ![floorPriceObj length]) {
        return ADX_BID_RESULT_INSUFFICIENT_DATA;
    }
    
    NSString * floorPriceString = [NSString stringWithFormat:@"%@", floorPriceObj];
    ADXDebugLog(@"floor_price: %@", floorPriceString);
    double floorPrice = [floorPriceString doubleValue];
    
    /// ADX eCPM
    id ecpmObj = [adxLocalData objectForKey:@"ecpm"];
    if (ecpmObj == nil || ![ecpmObj respondsToSelector:@selector(doubleValue)]) {
        return ADX_BID_RESULT_INSUFFICIENT_DATA;
    }
    if ([ecpmObj isKindOfClass:[NSString class]] && ![ecpmObj length]) {
        ADXDebugLog(@"the length of eCPM is zero");
        return ADX_BID_RESULT_INSUFFICIENT_DATA;
    }
    
    NSString * eCPMString = [NSString stringWithFormat:@"%@", ecpmObj];
    ADXDebugLog(@"eCPMString: %@", eCPMString);
    double adxECPM = [eCPMString doubleValue];
    
    /// Compare ADX-eCPM to Floor Price
    if(floorPrice == 0 || adxECPM == 0) {
        ADXDebugLog(@"ZeroPrice, floorPrice: %f, adxECPM: %f", floorPrice, adxECPM);
        return ADX_BID_RESULT_ZERO_PRICE;
    }
    /// ADX-eCPM should be higher than floor price
    if(adxECPM < floorPrice) {
        ADXDebugLog(@"eCPM (%f) is lower than the floor price (%f)", adxECPM, floorPrice);
        return ADX_BID_RESULT_LOW_PRICE;
    }

    ADXDebugLog(@"Found Ad that meet the price");
    return ADX_BID_RESULT_MATCHED;
}

#pragma mark - RewardedAd
- (void)loadRewardedAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters
                          andNotify:(nonnull id<MARewardedAdapterDelegate>)delegate 
{
    ADXBidCompareResult compareResult = [self isHigherThanOrEqualToFloorPrice:parameters];
    if(compareResult == ADX_BID_RESULT_MATCHED) {
        if([delegate respondsToSelector:@selector(didLoadRewardedAd)]) {
            self.rewardedDelegate = delegate;
            ADXDebugLog(@"didLoadRewardedAd");
            [delegate didLoadRewardedAd];
        }
        return;
    }
    
    MAAdapterError * error = [MAAdapterError errorWithCode:MAAdapterError.errorCodeBadRequest];
    switch (compareResult) {
        case ADX_BID_RESULT_LOW_PRICE:
            error = [MAAdapterError errorWithCode:MAAdapterError.errorCodeNoFill];
            break;
        default:
            break;
    }
    
    if([delegate respondsToSelector:@selector(didFailToLoadRewardedAdWithError:)]) {
        ADXDebugLog(@"didFailToLoadRewardedAdWithError:");
        [delegate didFailToLoadRewardedAdWithError:error];
    }
}

- (void)showRewardedAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters 
                          andNotify:(nonnull id<MARewardedAdapterDelegate>)delegate
{
    ADXDebugLog(@"placementIdentifier: %@", parameters.thirdPartyAdPlacementIdentifier);
    UIViewController * rootVC = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    if(self.loadedAd == nil 
       || rootVC == nil 
       || ![self.loadedAd respondsToSelector:@selector(setDelegate:)] 
       || ![self.loadedAd respondsToSelector:@selector(showAdFromRootViewController:)]) 
    {
        ADXDebugLog(@"didFailToDisplayRewardedAdWithError:");
        MAAdapterError * error = [MAAdapterError errorWithCode:MAAdapterError.errorCodeAdDisplayFailedError];
        [delegate didFailToDisplayRewardedAdWithError:error];
        return;
    }
    // ADXMediationRewardedAd
    ADXDebugLog(@"showAdFromRootViewController:");
    [self.loadedAd performSelector:@selector(setDelegate:) withObject:self];
    [self.loadedAd performSelector:@selector(showAdFromRootViewController:) withObject:rootVC];
}

#pragma mark - InterstitialAd
- (void)loadInterstitialAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters
                              andNotify:(nonnull id<MAInterstitialAdapterDelegate>)delegate
{
    ADXBidCompareResult compareResult = [self isHigherThanOrEqualToFloorPrice:parameters];
    if(compareResult == ADX_BID_RESULT_MATCHED) {
        if([delegate respondsToSelector:@selector(didLoadInterstitialAd)]) {
            self.interstitialDelegate = delegate;
            ADXDebugLog(@"didLoadInterstitialAd");
            [delegate didLoadInterstitialAd];
        }
        return;
    }
    
    MAAdapterError * error = [MAAdapterError errorWithCode:MAAdapterError.errorCodeBadRequest];
    switch (compareResult) {
        case ADX_BID_RESULT_LOW_PRICE:
            error = [MAAdapterError errorWithCode:MAAdapterError.errorCodeNoFill];
            break;
        default:
            break;
    }
    
    if([delegate respondsToSelector:@selector(didFailToLoadInterstitialAdWithError:)]) {
        ADXDebugLog(@"didFailToLoadInterstitialAdWithError:");
        [delegate didFailToLoadInterstitialAdWithError:error];
    }
}

- (void)showInterstitialAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters 
                              andNotify:(nonnull id<MAInterstitialAdapterDelegate>)delegate
{
    ADXDebugLog(@"placementIdentifier: %@", parameters.thirdPartyAdPlacementIdentifier);
    UIViewController * rootVC = parameters.presentingViewController ?: [ALUtils topViewControllerFromKeyWindow];
    if(self.loadedAd == nil
       || rootVC == nil
       || ![self.loadedAd respondsToSelector:@selector(setDelegate:)]
       || ![self.loadedAd respondsToSelector:@selector(showAdFromRootViewController:)])
    {
        MAAdapterError * error = [MAAdapterError errorWithCode:MAAdapterError.errorCodeAdDisplayFailedError];
        ADXDebugLog(@"didFailToDisplayInterstitialAdWithError:");
        [delegate didFailToDisplayInterstitialAdWithError:error];
        return;
    }
    // ADXMediationInterstitialAd
    ADXDebugLog(@"showAdFromRootViewController:");
    [self.loadedAd performSelector:@selector(setDelegate:) withObject:self];
    [self.loadedAd performSelector:@selector(showAdFromRootViewController:) withObject:rootVC];
}

#pragma mark - BannerAd
- (void)loadAdViewAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters 
                         adFormat:(nonnull MAAdFormat *)adFormat 
                        andNotify:(nonnull id<MAAdViewAdapterDelegate>)delegate
{
    ADXBidCompareResult compareResult = [self isHigherThanOrEqualToFloorPrice:parameters];
    if(compareResult == ADX_BID_RESULT_MATCHED) {
        if([self.loadedAd respondsToSelector:@selector(setDelegate:)] &&
           [delegate respondsToSelector:@selector(didLoadAdForAdView:)])
        {
            [self.loadedAd performSelector:@selector(setDelegate:) withObject:self];
            self.bannerDelegate = delegate;
            ADXDebugLog(@"didLoadAdForAdView:");
            [delegate didLoadAdForAdView:self.bannerView];
            return;
        }
    }
    
    MAAdapterError * error = [MAAdapterError errorWithCode:MAAdapterError.errorCodeBadRequest];
    switch (compareResult) {
        case ADX_BID_RESULT_LOW_PRICE:
            error = [MAAdapterError errorWithCode:MAAdapterError.errorCodeNoFill];
            break;
        default:
            break;
    }
    
    if([delegate respondsToSelector:@selector(didFailToLoadAdViewAdWithError:)]) {
        ADXDebugLog(@"didFailToLoadAdViewAdWithError:");
        [delegate didFailToLoadAdViewAdWithError:error];
    }
}

#pragma mark - NativeAd
- (void)loadNativeAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters
                        andNotify:(nonnull id<MANativeAdAdapterDelegate>)delegate
{
    ADXBidCompareResult compareResult = [self isHigherThanOrEqualToFloorPrice:parameters];
    if(compareResult == ADX_BID_RESULT_MATCHED) {
        // Create a 'MANativeAd' instance without data for rendering native Ad, and then pass it to 'didLoadAdForNativeAd' delegate
        MANativeAd * maAd = [[MANativeAd alloc] initWithFormat:[MAAdFormat native]
                                                  builderBlock:^(MANativeAdBuilder * builder) {
            // do nothing
        }];
        ADXDebugLog(@"didLoadAdForNativeAd:withExtraInfo:");
        [delegate didLoadAdForNativeAd:maAd withExtraInfo:@{}];
        return;
    }
    
    MAAdapterError * error = [MAAdapterError errorWithCode:MAAdapterError.errorCodeBadRequest];
    switch (compareResult) {
        case ADX_BID_RESULT_LOW_PRICE:
            error = [MAAdapterError errorWithCode:MAAdapterError.errorCodeNoFill];
            break;
        default:
            break;
    }
    
    if([delegate respondsToSelector:@selector(didFailToLoadNativeAdWithError:)]) {
        ADXDebugLog(@"didFailToLoadNativeAdWithError:");
        [delegate didFailToLoadNativeAdWithError:error];
    }
}

#pragma mark - ADXMediationRewardedAdDelegate, ADXMediationInterstitialAdDelegate, ADXMediationBannerAdDelegate
- (void)willPresentScreen {
    // rewardedDelegate
    if(self.rewardedDelegate) {
        id<MARewardedAdapterDelegate> delegate = self.rewardedDelegate;
        if(!delegate) { return; }
        if(![delegate respondsToSelector:@selector(didDisplayRewardedAd)]) { return; }
        ADXDebugLog(@"didDisplayRewardedAd");
        [delegate didDisplayRewardedAd];
    }
    // interstitialDelegate
    if(self.interstitialDelegate) {
        id<MAInterstitialAdapterDelegate> delegate = self.interstitialDelegate;
        if(!delegate) { return; }
        if(![delegate respondsToSelector:@selector(didDisplayInterstitialAd)]) { return; }
        ADXDebugLog(@"didDisplayInterstitialAd");
        [delegate didDisplayInterstitialAd];
    }
}

- (void)willDismissScreen {
    // rewardedDelegate
    if(self.rewardedDelegate) {
        id<MARewardedAdapterDelegate> delegate = self.rewardedDelegate;
        if(!delegate) { return; }
        if(![delegate respondsToSelector:@selector(didHideRewardedAd)]) { return; }
        ADXDebugLog(@"didHideRewardedAd");
        [delegate didHideRewardedAd];
    }
    // interstitialDelegate
    if(self.interstitialDelegate) {
        id<MAInterstitialAdapterDelegate> delegate = self.interstitialDelegate;
        if(!delegate) { return; }
        if(![delegate respondsToSelector:@selector(didHideInterstitialAd)]) { return; }
        ADXDebugLog(@"didHideInterstitialAd");
        [delegate didHideInterstitialAd];
    }
}

- (void)didClickAd {
    // rewardedDelegate
    if(self.rewardedDelegate) {
        id<MARewardedAdapterDelegate> delegate = self.rewardedDelegate;
        if(!delegate) { return; }
        if(![delegate respondsToSelector:@selector(didClickRewardedAd)]) { return; }
        ADXDebugLog(@"didClickRewardedAd");
        [delegate didClickRewardedAd];
    }
    // interstitialDelegate
    if(self.interstitialDelegate) {
        id<MAInterstitialAdapterDelegate> delegate = self.interstitialDelegate;
        if(!delegate) { return; }
        if(![delegate respondsToSelector:@selector(didClickRewardedAd)]) { return; }
        ADXDebugLog(@"didClickInterstitialAd");
        [delegate didClickInterstitialAd];
    }
    // bannerDelegate
    if(self.bannerDelegate) {
        id<MAAdViewAdapterDelegate> delegate = self.bannerDelegate;
        if(!delegate) { return; }
        if(![delegate respondsToSelector:@selector(didClickAdViewAd)]) { return; }
        ADXDebugLog(@"didClickAdViewAd");
        [delegate didClickAdViewAd];
    }
}

- (void)didRewardUserWithReward:(ADXReward *)reward {
    // rewardedDelegate
    id<MARewardedAdapterDelegate> delegate = self.rewardedDelegate;
    if(!delegate) { return; }
    if(![delegate respondsToSelector:@selector(didRewardUserWithReward:)]) { return; }
    ADXDebugLog(@"didRewardUserWithReward:");
    [delegate didRewardUserWithReward:self.reward];
}

@end

