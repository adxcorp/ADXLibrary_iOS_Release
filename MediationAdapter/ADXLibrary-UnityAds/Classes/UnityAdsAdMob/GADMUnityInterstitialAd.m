// Copyright 2020 Google LLC.
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

#import "GADMUnityInterstitialAd.h"
#import "GADMAdapterUnity.h"
#import "GADMAdapterUnityConstants.h"
#import "GADMAdapterUnityUtils.h"
#import "GADUnityError.h"

#import "ADXLogUtil.h"

@implementation GADMUnityInterstitialAd {
  NSString *_placementID;
  NSString *_gameID;
  BOOL _isLoading;
  /// Connector from Google Mobile Ads SDK to receive ad configurations.
  __weak id<GADMAdNetworkConnector> _connector;

  /// Adapter for receiving ad request notifications.
  __weak id<GADMAdNetworkAdapter> _adapter;

  /// Serializes  dispatch queue.
  dispatch_queue_t _lockQueue;
}

/// A map to keep track loaded Placement IDs
static NSMapTable<NSString *, GADMUnityInterstitialAd *> *_placementInUse;

- (instancetype)initWithGADMAdNetworkConnector:(nonnull id<GADMAdNetworkConnector>)connector
                                       adapter:(nonnull id<GADMAdNetworkAdapter>)adapter {
  self = [super init];
  if (self) {
    _adapter = adapter;
    _connector = connector;
    _placementInUse = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                                            valueOptions:NSPointerFunctionsWeakMemory];
    _lockQueue = dispatch_queue_create("unityAds-rewardedAd", DISPATCH_QUEUE_SERIAL);
  }
  return self;
}

- (void)getInterstitial {
  ADXLogEvent(ADX_PLATFORM_UNITYADS, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_LOAD);

  id<GADMAdNetworkConnector> strongConnector = _connector;
  id<GADMAdNetworkAdapter> strongAdapter = _adapter;

  if (!strongConnector) {
    NSLog(@"Unity Ads Adapter Error: No GADMAdNetworkConnector found.");
    return;
  }

  if (!strongAdapter) {
    NSLog(@"Unity Ads Adapter Error: No GADMAdNetworkAdapter found.");
    return;
  }

  _gameID = [[[strongConnector credentials] objectForKey:kGADMAdapterUnityGameID] copy];
  _placementID = [[[strongConnector credentials] objectForKey:kGADMAdapterUnityPlacementID] copy];
  if (!_gameID || !_placementID) {
    NSError *error = GADMAdapterUnityErrorWithCodeAndDescription(
        GADMAdapterUnityErrorInvalidServerParameters, @"Game ID and Placement ID cannot be nil.");
    [strongConnector adapter:strongAdapter didFailAd:error];
    return;
  }

  if (![UnityAds isInitialized]) {
    [[GADMAdapterUnity alloc] initializeWithGameID:_gameID withCompletionHandler:nil];
  }

  __block GADMUnityInterstitialAd *interstitialAd = nil;
  dispatch_sync(_lockQueue, ^{
    interstitialAd = [_placementInUse objectForKey:_placementID];
  });

  if (interstitialAd) {
    if (strongConnector && strongAdapter) {
      NSString *errorMsg = [NSString
          stringWithFormat:@"An ad is already loading for placement ID: %@.", _placementID];
      NSError *error = GADMAdapterUnityErrorWithCodeAndDescription(
          GADMAdapterUnityErrorAdAlreadyLoaded, errorMsg);
      [strongConnector adapter:strongAdapter didFailAd:error];
    }
    return;
  }

  dispatch_async(_lockQueue, ^{
    GADMAdapterUnityMapTableSetObjectForKey(_placementInUse, self->_placementID, self);
  });

  [UnityAds load:_placementID loadDelegate:self];
}

- (void)presentInterstitialFromRootViewController:(UIViewController *)rootViewController {
  dispatch_async(_lockQueue, ^{
    GADMAdapterUnityMapTableRemoveObjectForKey(_placementInUse, self->_placementID);
  });

  // We will send adapterWillPresentInterstitial callback before presenting unity ad because the ad
  // has already loaded.
  id<GADMAdNetworkConnector> strongConnector = _connector;
  id<GADMAdNetworkAdapter> strongAdapter = _adapter;

  if (!strongConnector) {
    NSLog(@"Unity Ads Adapter Error: No GADMAdNetworkConnector found.");
    return;
  }

  if (!strongAdapter) {
    NSLog(@"Unity Ads Adapter Error: No GADMAdNetworkAdapter found.");
    return;
  }

  if (![UnityAds isReady:_placementID]) {
    NSError *error = GADMAdapterUnityErrorWithCodeAndDescription(
        GADMAdapterUnityErrorShowAdNotReady, @"Failed to show Unity Ads interstitial.");
    [strongConnector adapter:strongAdapter didFailAd:error];
    return;
  }

  [UnityAds addDelegate:self];
  [strongConnector adapterWillPresentInterstitial:strongAdapter];
  [UnityAds show:rootViewController placementId:_placementID];
}

#pragma mark - Unity Delegate Methods

- (void)unityAdsPlacementStateChanged:(NSString *)placementId
                             oldState:(UnityAdsPlacementState)oldState
                             newState:(UnityAdsPlacementState)newState {
}

- (void)unityAdsDidFinish:(NSString *)placementID withFinishState:(UnityAdsFinishState)state {
  ADXLogEvent(ADX_PLATFORM_UNITYADS, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_CLOSED);

  [UnityAds removeDelegate:self];
  id<GADMAdNetworkConnector> strongNetworkConnector = _connector;
  id<GADMAdNetworkAdapter> strongAdapter = _adapter;
  if (strongNetworkConnector && strongAdapter) {
    [strongNetworkConnector adapterWillDismissInterstitial:strongAdapter];
    [strongNetworkConnector adapterDidDismissInterstitial:strongAdapter];
  }
}

- (void)unityAdsDidClick:(NSString *)placementID {
  ADXLogEvent(ADX_PLATFORM_UNITYADS, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_CLICK);

  id<GADMAdNetworkConnector> strongNetworkConnector = _connector;
  id<GADMAdNetworkAdapter> strongAdapter = _adapter;
  // The Unity Ads SDK doesn't provide an event for leaving the application, so the adapter assumes
  // that a click event indicates the user is leaving the application for a browser or deeplink, and
  // notifies the Google Mobile Ads SDK accordingly.
  if (strongNetworkConnector && strongAdapter) {
    [strongNetworkConnector adapterDidGetAdClick:strongAdapter];
    [strongNetworkConnector adapterWillLeaveApplication:strongAdapter];
  }
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message {
  NSString *errorMsg = [NSString stringWithFormat:@"%@, %@", ADX_EVENT_LOAD_FAILURE, message];
  ADXLogEvent(ADX_PLATFORM_UNITYADS, ADX_INVENTORY_INTERSTITIAL, errorMsg);

  [UnityAds removeDelegate:self];
  id<GADMAdNetworkConnector> strongNetworkConnector = _connector;
  id<GADMAdNetworkAdapter> strongAdapter = _adapter;

  if (error == kUnityAdsErrorShowError) {
    if (strongNetworkConnector && strongAdapter) {
      [strongNetworkConnector adapterWillDismissInterstitial:strongAdapter];
      [strongNetworkConnector adapterDidDismissInterstitial:strongAdapter];
    }
  }
}

- (void)unityAdsDidStart:(nonnull NSString *)placementId {
    ADXLogEvent(ADX_PLATFORM_UNITYADS, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_IMPRESSION);

  // nothing to do
  // todo: double check if impression need this
}

- (void)unityAdsReady:(nonnull NSString *)placementId {
  // Logic to mark a placement ready has moved to the UnityAdsLoadDelegate function
  // unityAdsAdLoaded.
}

#pragma mark - UnityAdsLoadDelegate Methods

- (void)unityAdsAdFailedToLoad:(nonnull NSString *)placementId {
  ADXLogEvent(ADX_PLATFORM_UNITYADS, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_LOAD_FAILURE);

  dispatch_async(_lockQueue, ^{
    GADMAdapterUnityMapTableRemoveObjectForKey(_placementInUse, self->_placementID);
  });

  id<GADMAdNetworkConnector> strongConnector = _connector;
  id<GADMAdNetworkAdapter> strongAdapter = _adapter;
  if (strongConnector && strongAdapter) {
    NSString *errorMsg =
        [NSString stringWithFormat:@"No ad available for the placement ID: %@", _placementID];
    NSError *error = GADMAdapterUnityErrorWithCodeAndDescription(
        GADMAdapterUnityErrorPlacementStateNoFill, errorMsg);
    [strongConnector adapter:strongAdapter didFailAd:error];
  }
}

- (void)unityAdsAdLoaded:(nonnull NSString *)placementId {
  ADXLogEvent(ADX_PLATFORM_UNITYADS, ADX_INVENTORY_INTERSTITIAL, ADX_EVENT_LOAD_SUCCESS);

  id<GADMAdNetworkConnector> strongNetworkConnector = _connector;
  id<GADMAdNetworkAdapter> strongAdapter = _adapter;

  if (strongNetworkConnector && strongAdapter) {
    [strongNetworkConnector adapterDidReceiveInterstitial:strongAdapter];
  }
}

@end
