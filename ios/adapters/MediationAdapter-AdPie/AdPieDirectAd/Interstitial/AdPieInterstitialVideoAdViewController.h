#import "AdPieInterstitialAdViewController.h"
#import "AdPieRewardedAdViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class AdPieVideoAdData;

@protocol AdPieInterstitialVideoAdViewController;

@interface AdPieInterstitialVideoAdViewController : AdPieRewardedAdViewController

@property (weak, nullable) id<AdPieInterstitialAdViewControllerDelegate> adDelegate;

- (BOOL)loadAdWithData:(AdPieVideoAdData *)adData;
- (void)show;
@end

NS_ASSUME_NONNULL_END
