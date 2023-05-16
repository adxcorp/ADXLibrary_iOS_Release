//
//  ADXTableViewAdPlacerDelegate.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "ADXAdPlacer.h"

@class ADXTableViewAdPlacer;

@protocol ADXTableViewAdPlacerDelegate <ADXAdPlacerDelegate>

@optional

/*
 This method is called when a native ad, placed by the table view ad placer, will present a modal view controller.

 @param placer The table view ad placer that contains the ad displaying the modal.
 */
- (void)nativeAdWillPresentModalForTableViewAdPlacer:(ADXTableViewAdPlacer *)placer;

/*
 This method is called when a native ad, placed by the table view ad placer, did dismiss its modal view controller.

 @param placer The table view ad placer that contains the ad that dismissed the modal.
 */
- (void)nativeAdDidDismissModalForTableViewAdPlacer:(ADXTableViewAdPlacer *)placer;

/*
 This method is called when a native ad, placed by the table view ad placer, will cause the app to background due to user interaction with the ad.

 @param placer The table view ad placer that contains the ad causing the app to background.
 */
- (void)nativeAdWillLeaveApplicationFromTableViewAdPlacer:(ADXTableViewAdPlacer *)placer;

@end
