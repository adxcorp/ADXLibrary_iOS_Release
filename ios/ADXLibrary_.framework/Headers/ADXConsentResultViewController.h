//
//  ADXConsentResultViewController.h
//  ADXLibrary
//
//  Created by Eleanor Choi on 2018. 5. 29..
//

#import <UIKit/UIKit.h>

@interface ADXConsentResultViewController : UIViewController
@property (nonatomic, copy) void (^confirmedBlock)(BOOL);
@end
