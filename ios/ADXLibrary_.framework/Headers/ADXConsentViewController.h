//
//  ADXConsentViewController.h
//  ADXLibrary
//
//  Created by Eleanor Choi on 2018. 5. 29..
//

#import <UIKit/UIKit.h>

@protocol ADXConsentDelegate
- (void)consentComplete;
@end

@interface ADXConsentViewController : UIViewController
@property (nonatomic, copy) void (^confirmedBlock)(BOOL);
@end
