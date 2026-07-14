//
//  ADXTnkNativeAd.m
//  ADXLibrary-Tnk
//
//  Created by JCLEE on 2023/02/08.
//

#import "ADXTnkUtil.h"
#import "ADXTnkNativeAd.h"
#import "ADXTnkAdapter.h"
#import <ADXLibrary/ADXNativeAdRendering.h>
#import <ADXLibrary/ADXNativeAd.h>

@interface ADXTnkNativeAd () <TnkAdListener>

@property (assign) BOOL adLoaded;
@property (assign) BOOL isVisible;
@property (strong) Class renderingViewClass;
@property (strong) TnkNativeAdItem *adItem;
@property (strong) UIView<ADXNativeAdRendering> *adView;
@end

@interface ADXTnkTapGestureRecognizer : UITapGestureRecognizer
@property (strong) NSString *url;
@end

@implementation ADXTnkTapGestureRecognizer
@end


@implementation ADXTnkNativeAd

@synthesize delegate;

- (void)dealloc {
    ADXDebugLog(@"dealloc");
    if(self.adView){
        [TnkNativeAdItem detach:self.adView];
        self.adView = nil;
    }
    self.adItem = nil;
    self.delegate = nil;
}

- (BOOL)isLoaded {
    return self.adLoaded;
}

- (void)loadAdWithMediationData:(ADXMediationData *)mediation
             renderingViewClass:(Class)renderingViewClass
             rootViewController:(UIViewController *)rootViewController
{
    ADXDebugLog(@"loadAdWithMediationData");
    self.adLoaded = NO;
    if (renderingViewClass == nil) {
        NSError *error = [NSError errorWithDomain:ADXTnkErrorDomain code:ADXAdErrorInvalidLayout
                                      description:@"Rendering Class is nil"];
        ADXDebugLogError(@"%@", error.description);
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        return;
    }
    
    self.renderingViewClass = renderingViewClass;
    
    if (mediation == nil || mediation.customEventParams == nil) {
        NSError *error = [NSError errorWithDomain:ADXTnkErrorDomain code:ADXAdErrorNoMediationData];
        ADXDebugLogError(@"%@", error.description);
        if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
            [self.delegate didFailToLoadAdWithError:error];
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    // TnkHandler 정의
    typedef void(^TnkHandler)(BOOL success, NSError *_Nullable error);
    TnkHandler handler = ^(BOOL success, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (error) {
            ADXDebugLogError(@"%@", error.description);
            strongSelf.adLoaded = NO;
            if ([strongSelf.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
                [strongSelf.delegate didFailToLoadAdWithError:error];
            }
            return;
        }
        // TnkNativeAdItem 초기화
        NSString *placementId = [mediation.customEventParams objectForKey:@"placement_id"];
        TnkNativeAdItem *adItem = [[TnkNativeAdItem alloc] initWithPlacementId:placementId adListener:strongSelf];
        // SDK 초기화 성공 시, 광고로드
        [adItem load];
    };
    
    [ADXTnkAdapter initializeSdkWithConfiguration:mediation.customEventParams
                                completionHandler:handler];
}

- (UIView *)retrieveAdViewWithError:(NSError **)error {
    if(self.adItem == nil || self.adLoaded == NO){
        ADXLogDebug(@"Native ad is not ready to be presented.");
        return nil;
    }
    
    if ([self.renderingViewClass respondsToSelector:@selector(nibForAd)]) {
        self.adView = (UIView<ADXNativeAdRendering> *)[[[self.renderingViewClass nibForAd] instantiateWithOwner:nil options:nil] firstObject];
    } else {
        self.adView = [[self.renderingViewClass alloc] init];
    }

    self.adView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    // Main Text Label
    if ([self.adView respondsToSelector:@selector(nativeMainTextLabel)] &&
        self.adView.nativeMainTextLabel) {
        self.adView.nativeMainTextLabel.text = [self.adItem getDescription];
    }
    
    // Title Label
    if ([self.adView respondsToSelector:@selector(nativeTitleTextLabel)] &&
        self.adView.nativeTitleTextLabel) {
        self.adView.nativeTitleTextLabel.text = [self.adItem getTitle];
    }
    
    // Icon Image
    if ([self.adView respondsToSelector:@selector(nativeIconImageView)] &&
        self.adView.nativeIconImageView)
    {
        self.adView.nativeIconImageView.image = [self.adItem getIconImage];
    }
    
    // Click 제스쳐를 등록할 UIView 객체를 담을 Array
    NSMutableArray *clickViewArray = [NSMutableArray array];
    
    // Main Image
    if ([self.adView respondsToSelector:@selector(nativeMainImageView)] &&
        self.adView.nativeMainImageView)
    {
        UIImage* image = [self.adItem getMainImage];
        if(image){
            self.adView.nativeMainImageView.image = image;
            [clickViewArray addObject:self.adView.nativeMainImageView];
        }
    }
    
    // CTA 버튼
    if ([self.adView respondsToSelector:@selector(nativeCallToActionButton)] &&
        self.adView.nativeCallToActionButton)
    {
        NSString *cta = [self.adItem getCallToAction];
        [self.adView.nativeCallToActionButton setHidden:YES];
        if([cta length]){
            [self.adView.nativeCallToActionButton setHidden:NO];
            [self.adView.nativeCallToActionButton setTitle:cta forState:UIControlStateNormal];
            [clickViewArray addObject:self.adView.nativeCallToActionButton];
        }
    }
    
    // 클릭 이벤트 추가
    if([clickViewArray count]){
        [self.adItem attach:self.adView clickViews:clickViewArray];
    }
    
    // Privacy Icon (Policy Icon)
    if ([self.adView respondsToSelector:@selector(nativePrivacyInformationIconImageView)] &&
        self.adView.nativePrivacyInformationIconImageView)
    {
        UIImage *image = [self.adItem getAdProviderLogoImage];
        NSString *url = [self.adItem getAdProviderPolicyUrl];
        UIImageView *iconView = self.adView.nativePrivacyInformationIconImageView;
        [iconView setHidden:YES];
        if(image && [url length]) {
            [iconView setHidden:NO];
            [iconView setUserInteractionEnabled:YES];
            iconView.image = image;
            ADXTnkTapGestureRecognizer *gesture = [[ADXTnkTapGestureRecognizer alloc] initWithTarget:self action:@selector(privacyIconTapGesture:)];
            gesture.url = url;
            [iconView addGestureRecognizer:gesture];
        }
    }
    
    return self.adView;
}

- (void) privacyIconTapGesture:(ADXTnkTapGestureRecognizer *) gesture {
    if(![gesture.url length]){ return; }
    NSURL *url = [NSURL URLWithString:gesture.url];
    // iOS 10 이상
    if (@available(iOS 10, *)) {
        UIApplication *application = [UIApplication sharedApplication];
        [application openURL:url options:@{} completionHandler:^(BOOL success) {}];
        return;
    }
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:gesture.url]];
    #pragma clang diagnostic pop
}

@end


@implementation ADXTnkNativeAd (TnkAdEvents)

- (void)onLoad:(id<TnkAdItem>)adItem {
    ADXLogDebug(@"onLoad");
    self.adItem = (TnkNativeAdItem*)adItem;
    self.adLoaded = adItem.isLoaded;
    if ([self.delegate respondsToSelector:@selector(didLoadAd)]) {
        [self.delegate didLoadAd];
    }
}

- (void)onError:(id <TnkAdItem> _Nonnull)adItem error:(enum AdError)error {
    ADXLogError(@"onError, %d", error);
    self.adLoaded = NO;
    if ([self.delegate respondsToSelector:@selector(didFailToLoadAdWithError:)]) {
        [self.delegate didFailToLoadAdWithError:[NSError errorWithDomain:ADXTnkErrorDomain
                                                                    code:ADXAdErrorNoFill]];
    }
}

- (void)onClose:(id <TnkAdItem> _Nonnull)adItem type:(enum AdClose)type {
    ADXLogDebug(@"onClose");
    self.adLoaded = NO;
}

- (void)onClick:(id <TnkAdItem> _Nonnull)adItem {
    ADXLogDebug(@"onClick");
    if ([self.delegate respondsToSelector:@selector(didClickAd)]) {
        [self.delegate didClickAd];
    }
}

- (void)onShow:(id <TnkAdItem> _Nonnull)adItem {
    ADXLogDebug(@"onShow");
    if ([self.delegate respondsToSelector:@selector(trackImpression)]) {
        [self.delegate trackImpression];
    }
}

@end

