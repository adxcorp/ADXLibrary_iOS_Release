#import <objc/runtime.h>
#import "AdPieInterstitialVideoAdViewController.h"
#import <ADXLibrary/ADXAdError.h>
#import <ADXLibrary/ADXAdLogEvent.h>


@implementation AdPieInterstitialVideoAdViewController

#pragma mark - Methods overrided
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)loadAdWithData:(AdPieVideoAdData *)adData {
    if (adData == nil || adData.icType != AdPieAdContentTypeInterstitialIVideo) {
        if ([self.adDelegate respondsToSelector:@selector(interstitialAdDidFailToLoadWithError:)]) {
            [self.adDelegate interstitialAdDidFailToLoadWithError:[NSError errorWithCode:ADXAdErrorServerData]];
        }
        return NO;
    }
    
    if(![super loadAdWithData:adData]){
        if ([self.adDelegate respondsToSelector:@selector(interstitialAdDidFailToLoadWithError:)]) {
            [self.adDelegate interstitialAdDidFailToLoadWithError:[NSError errorWithCode:ADXAdErrorContentLoad]];
        }
        return NO;
    }
    
    if ([self.adDelegate respondsToSelector:@selector(interstitialAdDidLoad)]) {
        [self.adDelegate interstitialAdDidLoad];
    }
    return YES;
}

- (void)show {
    [super show];
    if ([self.adDelegate respondsToSelector:@selector(interstitialAdWillPresentScreen)]) {
        [self.adDelegate interstitialAdWillPresentScreen];
    }
}

- (void)clickLink {
    if ([super respondsToSelector:@selector(clickLink)]) {
        // 슈퍼클래스의 clickLink 호출
        Method method = class_getInstanceMethod([AdPieRewardedAdViewController class], @selector(clickLink));
        IMP imp = method_getImplementation(method);
        ((void (*)(id, SEL))imp)(self, @selector(clickLink));
    }
    
    if ([self.adDelegate respondsToSelector:@selector(interstitialAdDidClick)]) {
        [self.adDelegate interstitialAdDidClick];
    }
}

- (void)closeAd {
    ADXDebugLog(@"closeAd");
    // 매체에 종료 예정 알림
    if ([self.adDelegate respondsToSelector:@selector(interstitialAdWillDismissScreen)]) {
        [self.adDelegate interstitialAdWillDismissScreen];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        // 매체에 종료 완료 알림
        if ([weakSelf.adDelegate respondsToSelector:@selector(interstitialAdDidDismissScreen)]) {
            [weakSelf.adDelegate interstitialAdDidDismissScreen];
        }
    }];
}

@end
