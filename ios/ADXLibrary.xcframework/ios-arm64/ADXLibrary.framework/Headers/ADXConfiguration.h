//
//  ADXConfiguration.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ADXGdprConstants.h"
#import "ADXLogLevel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ADXConfiguration : NSObject

@property (strong, readonly) NSString *appId;
@property (assign, readonly) ADXGdprType gdprType;
@property (strong) NSArray<NSString*> * testDevices;
@property (nonatomic, assign) ADXLogLevel logLevel;

- (instancetype)initWithAppId:(NSString *)appId gdprType:(ADXGdprType)gdprType NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithAppId:(NSString *)appId 
                     gdprType:(ADXGdprType)gdprType
                  testDevices:(NSArray<NSString*> *) testDevices;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
+ (NSBundle *) mainAppBundle;
+ (UIInterfaceOrientationMask) plistSupportedOrientations;
+ (UIViewController *) getADXRootViewController;

@end

NS_ASSUME_NONNULL_END
