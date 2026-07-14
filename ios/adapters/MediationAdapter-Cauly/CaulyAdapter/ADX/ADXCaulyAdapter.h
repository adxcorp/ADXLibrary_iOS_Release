//
//  ADXCaulyAdapter.h
//  ADXLibrary-Cauly
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ADXLibrary/ADXMediationAdapter.h>

#import <CaulySDK/Cauly.h>
#import <CaulySDK/CaulyAdView.h>
#import <CaulySDK/CaulyInterstitialAd.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const ADXCaulyErrorDomain;

@interface ADXCaulyAdapter : NSObject <ADXMediationAdapter>

@end

NS_ASSUME_NONNULL_END
