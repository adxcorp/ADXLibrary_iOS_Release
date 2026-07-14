//
//  ADXAdPieAdapter.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ADXLibrary/ADXMediationAdapter.h>
#import <AdPieSDK/AdPieSDK.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const ADXAdPieErrorDomain;

@interface ADXAdPieAdapter : NSObject <ADXMediationAdapter>

+ (void)initializeAdPieSdk:(NSString *)mediaID
                completion:(void(^)(BOOL initialized, NSError * error))completion;

@end

NS_ASSUME_NONNULL_END
