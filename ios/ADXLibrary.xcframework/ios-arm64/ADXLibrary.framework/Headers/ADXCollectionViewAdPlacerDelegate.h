//
//  ADXCollectionViewAdPlacerDelegate.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "ADXAdPlacer.h"

@class ADXCollectionViewAdPlacer;

@protocol ADXCollectionViewAdPlacerDelegate <ADXAdPlacerDelegate>

@optional

/*
 This method is called when a native ad, placed by the collection view ad placer, will present a modal view controller.

 @param placer The collection view ad placer that contains the ad displaying the modal.
 */
- (void)nativeAdWillPresentModalForCollectionViewAdPlacer:(ADXCollectionViewAdPlacer *)placer;

/*
 This method is called when a native ad, placed by the collection view ad placer, did dismiss its modal view controller.

 @param placer The collection view ad placer that contains the ad that dismissed the modal.
 */
- (void)nativeAdDidDismissModalForCollectionViewAdPlacer:(ADXCollectionViewAdPlacer *)placer;

/*
 This method is called when a native ad, placed by the collection view ad placer, will cause the app to background due to user interaction with the ad.

 @param placer The collection view ad placer that contains the ad causing the app to background.
 */
- (void)nativeAdWillLeaveApplicationFromCollectionViewAdPlacer:(ADXCollectionViewAdPlacer *)placer;

@end
