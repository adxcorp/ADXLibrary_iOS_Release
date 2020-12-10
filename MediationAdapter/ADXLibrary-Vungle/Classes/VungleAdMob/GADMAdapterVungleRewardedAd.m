// Copyright 2019 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "GADMAdapterVungleRewardedAd.h"
#include <stdatomic.h>
#import "GADMAdapterVungleConstants.h"
#import "GADMAdapterVungleRouter.h"
#import "GADMAdapterVungleUtils.h"

#import "ADXLogUtil.h"

@interface GADMAdapterVungleRewardedAd () <GADMAdapterVungleDelegate>
@end

@implementation GADMAdapterVungleRewardedAd {
  /// Ad configuration for the ad to be loaded.
  GADMediationRewardedAdConfiguration *_adConfiguration;

  /// The completion handler to call when an ad loads successfully or fails.
  GADMediationRewardedLoadCompletionHandler _adLoadCompletionHandler;

  /// The ad event delegate to forward ad rendering events to the Google Mobile Ads SDK.
  id<GADMediationRewardedAdEventDelegate> _delegate;

  /// Indicates whether the rewarded ad is loaded.
  BOOL _isAdLoaded;
}

- (nonnull instancetype)
    initWithAdConfiguration:(nonnull GADMediationRewardedAdConfiguration *)adConfiguration
          completionHandler:(nonnull GADMediationRewardedLoadCompletionHandler)handler {
  self = [super init];
  if (self) {
    _adConfiguration = adConfiguration;

    __block atomic_flag adLoadHandlerCalled = ATOMIC_FLAG_INIT;
    __block GADMediationRewardedLoadCompletionHandler origAdLoadHandler = [handler copy];

    // Ensure the original completion handler is only called once, and is deallocated once called.
    _adLoadCompletionHandler = ^id<GADMediationRewardedAdEventDelegate>(
        id<GADMediationRewardedAd> rewardedAd, NSError *error) {
      if (atomic_flag_test_and_set(&adLoadHandlerCalled)) {
        return nil;
      }

      id<GADMediationRewardedAdEventDelegate> delegate = nil;
      if (origAdLoadHandler) {
        delegate = origAdLoadHandler(rewardedAd, error);
      }

      origAdLoadHandler = nil;
      return delegate;
    };
  }
  return self;
}

- (void)requestRewardedAd {
  self.desiredPlacement =
      [GADMAdapterVungleUtils findPlacement:_adConfiguration.credentials.settings
                              networkExtras:_adConfiguration.extras];
  if (!self.desiredPlacement.length) {
    NSError *error = GADMAdapterVungleErrorWithCodeAndDescription(
        GADMAdapterVungleErrorInvalidServerParameters, @"Placement ID not specified.");
    _adLoadCompletionHandler(nil, error);
    return;
  }

  if ([[GADMAdapterVungleRouter sharedInstance] hasDelegateForPlacementID:self.desiredPlacement]) {
    NSError *error = GADMAdapterVungleErrorWithCodeAndDescription(
        GADMAdapterVungleErrorAdAlreadyLoaded,
        @"Only a maximum of one ad per placement can be requested from Vungle.");
    _adLoadCompletionHandler(nil, error);
    return;
  }

  VungleSDK *sdk = [VungleSDK sharedSDK];

  if ([sdk isInitialized]) {
    [self loadRewardedAd];
    return;
  }

  NSString *appID = [GADMAdapterVungleUtils findAppID:_adConfiguration.credentials.settings];
  if (!appID) {
    NSError *error = GADMAdapterVungleErrorWithCodeAndDescription(
        GADMAdapterVungleErrorInvalidServerParameters, @"Vungle app ID not specified.");
    _adLoadCompletionHandler(nil, error);
    return;
  }
  [[GADMAdapterVungleRouter sharedInstance] initWithAppId:appID delegate:self];
}

- (void)loadRewardedAd {
  ADXLogEvent(ADX_PLATFORM_VUNGLE, ADX_INVENTORY_RV, ADX_EVENT_LOAD);

  NSError *error = [[GADMAdapterVungleRouter sharedInstance] loadAd:self.desiredPlacement
                                                       withDelegate:self];
  if (error) {
    ADXLogEvent(ADX_PLATFORM_VUNGLE, ADX_INVENTORY_RV, ADX_EVENT_LOAD_FAILURE);
      
    _adLoadCompletionHandler(nil, error);
  }
}

- (void)presentFromViewController:(nonnull UIViewController *)viewController {
  NSError *error = nil;
  if (![[GADMAdapterVungleRouter sharedInstance] playAd:viewController
                                               delegate:self
                                                 extras:[_adConfiguration extras]
                                                  error:&error]) {
    [_delegate didFailToPresentWithError:error];
  }
}

- (void)dealloc {
  _adLoadCompletionHandler = nil;
  _adConfiguration = nil;
}

#pragma mark - VungleRouter delegates

@synthesize desiredPlacement;

- (void)initialized:(BOOL)isSuccess error:(nullable NSError *)error {
  if (!isSuccess) {
    _adLoadCompletionHandler(nil, error);
    return;
  }
  [self loadRewardedAd];
}

- (void)adAvailable {
  if (_isAdLoaded) {
    // Already invoked an ad load callback.
    return;
  }
  _isAdLoaded = YES;
    
  ADXLogEvent(ADX_PLATFORM_VUNGLE, ADX_INVENTORY_RV, ADX_EVENT_LOAD_SUCCESS);

  if (_adLoadCompletionHandler) {
    _delegate = _adLoadCompletionHandler(self, nil);
  }

  if (!_delegate) {
    // In this case, the request for Vungle has been timed out. Clean up self.
    [[GADMAdapterVungleRouter sharedInstance] removeDelegate:self];
  }
}

- (void)didCloseAd {
  ADXLogEvent(ADX_PLATFORM_VUNGLE, ADX_INVENTORY_RV, ADX_EVENT_CLOSED);

  [_delegate didDismissFullScreenView];

  GADMAdapterVungleRewardedAd __weak *weakSelf = self;
  [[GADMAdapterVungleRouter sharedInstance] removeDelegate:weakSelf];
}

- (void)willCloseAd {
  [_delegate willDismissFullScreenView];
}

- (void)willShowAd {
  ADXLogEvent(ADX_PLATFORM_VUNGLE, ADX_INVENTORY_RV, ADX_EVENT_IMPRESSION);

  id<GADMediationRewardedAdEventDelegate> strongDelegate = _delegate;
  [strongDelegate willPresentFullScreenView];
  [strongDelegate reportImpression];
  [strongDelegate didStartVideo];
}

- (void)adNotAvailable:(nonnull NSError *)error {
  if (_isAdLoaded) {
    // Already invoked an ad load callback.
    return;
  }
  _adLoadCompletionHandler(nil, error);
  [[GADMAdapterVungleRouter sharedInstance] removeDelegate:self];
}

- (void)trackClick {
  ADXLogEvent(ADX_PLATFORM_VUNGLE, ADX_INVENTORY_RV, ADX_EVENT_CLICK);

  [_delegate reportClick];
}

- (void)rewardUser {
  ADXLogEvent(ADX_PLATFORM_VUNGLE, ADX_INVENTORY_RV, ADX_EVENT_REWARD);

  id<GADMediationRewardedAdEventDelegate> strongDelegate = _delegate;
  [strongDelegate didEndVideo];
  GADAdReward *reward =
      [[GADAdReward alloc] initWithRewardType:@"vungle"
                                 rewardAmount:[NSDecimalNumber decimalNumberWithString:@"1"]];
  [strongDelegate didRewardUserWithReward:reward];
}

- (void)willLeaveApplication {
  // Do nothing.
}

@end
