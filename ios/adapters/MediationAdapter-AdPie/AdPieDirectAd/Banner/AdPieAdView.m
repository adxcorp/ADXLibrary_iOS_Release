//
//  AdPieAdView.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "AdPieAdView.h"
#import "AdPieAdContentView.h"
#import "AdPieAdData.h"
#import <ADXLibrary/ADXAdError.h>
#import <ADXLibrary/ADXAdLogEvent.h>
#import <ADXLibrary/ADXHTTPNetworkSession.h>

typedef NS_ENUM(NSInteger, ADXBannerAdStatus) {
    ADXBannerAdStatusResume,
    ADXBannerAdStatusPause
};

@interface AdPieAdView () <AdPieAdContentViewDelegate>

@property (assign) int animationType;
@property (nonatomic, strong) AdPieAdContentView *adContentView;
@property (assign, getter=isShowingAdContent) BOOL showingAdContent;
@property BOOL hasClicked;
@property AdPieAdData * adData;
@end

@implementation AdPieAdView

#pragma mark - View Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setup];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.adContentView) {
        CGPoint center = CGPointMake(floorf(self.bounds.size.width / 2.0), floorf(self.bounds.size.height / 2.0));
        self.adContentView.center = center;
    }
}

- (void)dealloc {
    if (self.adContentView) {
        [self.adContentView removeFromSuperview];
        self.adContentView.delegate = nil;
        self.adContentView = nil;
    }
    
    self.delegate = nil;
}

#pragma mark - Setup

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    self.autoresizingMask = UIViewAutoresizingNone;
    self.showingAdContent = NO;
}

- (void)setupAnimation:(CATransition *)animation {
    switch (self.animationType) {
        case 0: // 효과 없음 (디폴트)
            [animation setType:kCATruncationNone];
            [animation setDuration:0.0];
            break;
        case 1: // 왼쪽에서 오른쪽 슬라이드
            [animation setType:kCATransitionPush];
            [animation setSubtype:kCATransitionFromLeft];
            [animation setDuration:1.0];
            break;
        case 2: // 오른쪽에서 왼쪽 슬라이드
            [animation setType:kCATransitionPush];
            [animation setSubtype:kCATransitionFromRight];
            [animation setDuration:1.0];
            break;
        case 3: // 위에서 아래로 슬라이드
            [animation setType:kCATransitionPush];
            [animation setSubtype:kCATransitionFromBottom];
            [animation setDuration:1.0];
            break;
        case 4: // 아래에서 위로 슬라이드
            [animation setType:kCATransitionPush];
            [animation setSubtype:kCATransitionFromTop];
            [animation setDuration:1.0];
            break;
        case 5: // 이전 광고가 서서히 사라지는 효과
            [animation setType:kCATransitionFade];
            [animation setDuration:2.0];
            break;
        default:
            [animation setType:kCATruncationNone];
            [animation setDuration:0.0];
            break;
    }
    
    [[self layer] addAnimation:animation forKey:nil];
}

- (void)setAdContentView:(AdPieAdContentView *)adContentView {
    @synchronized (self) {
        [self.adContentView removeFromSuperview];
        _adContentView = adContentView;
    }
    
    if (adContentView != nil) {
        [self addSubview:adContentView];
        [self setNeedsLayout];
        self.userInteractionEnabled = YES;
        
        CATransition *animation = [CATransition animation];
        [self setupAnimation:animation];
        
    } else {
        self.userInteractionEnabled = NO;
    }
}


#pragma mark - Load

- (void)loadAdWithData:(AdPieAdData *)adData {
    ADXDebugLog(@"loadAdWithData");
    
    @try {
        if (adData == nil) {
            if ([self.delegate respondsToSelector:@selector(adView:didFailToLoadWithError:)]) {
                [self.delegate adView:self didFailToLoadWithError:[NSError errorWithCode:ADXAdErrorServerData]];
            }
            
            return;
        }
        
        if (self.bounds.size.width < adData.width || self.bounds.size.height < adData.height) {
            if ([self.delegate respondsToSelector:@selector(adView:didFailToLoadWithError:)]) {
                [self.delegate adView:self didFailToLoadWithError:[NSError errorWithCode:ADXAdErrorInvalidLayout]];
            }
            
            return;
        }
        
        if (!self.isShowingAdContent) {
            self.showingAdContent = YES;
            
        } else {
            ADXLogDebug(@"Previous ad content is showing.");
            
            if ([self.delegate respondsToSelector:@selector(adView:didFailToLoadWithError:)]) {
                [self.delegate adView:self didFailToLoadWithError:[NSError errorWithCode:ADXAdErrorContentLoad]];
            }
            return;
        }
        
        self.adData = adData;
        self.hasClicked = NO;
        
        self.animationType = adData.animationType;
        self.adContentView = [[AdPieAdContentView alloc] initWithFrame:self.bounds];
        [self.adContentView setBannerAdData:adData delegate:self];
        [self.adContentView showContent];
        
    } @catch (NSException *exception) {
        ADXDebugLogError(@"%@", exception);
        
        if ([self.delegate respondsToSelector:@selector(adView:didFailToLoadWithError:)]) {
            [self.delegate adView:self didFailToLoadWithError:[NSError errorWithCode:ADXAdErrorInternal]];
        }
    }
}


#pragma mark - ADXAdContentViewDelegate

- (void)adContentViewDidLoad:(AdPieAdContentView *)adContentView {
    ADXDebugLog(@"adContentViewDidLoad");
    
    [self setAdContentView:adContentView];
    
    if ([self.delegate respondsToSelector:@selector(adViewDidLoad:)]) {
        [self.delegate adViewDidLoad:self];
    }
}

- (void)adContentView:(AdPieAdContentView *)adContentView didFailToLoadWithError:(NSError *)error {
    ADXDebugLogError(@"adContentView:didFailToLoadWithError: %@", error.description);
    
    if ([self.delegate respondsToSelector:@selector(adView:didFailToLoadWithError:)]) {
        [self.delegate adView:self didFailToLoadWithError:error];
    }
}
- (void)adContentViewDidClick:(AdPieAdContentView *)adContentView {
    ADXDebugLog(@"adContentViewDidClick");
    if ([self.delegate respondsToSelector:@selector(adViewDidClick:)]) {
        [self.delegate adViewDidClick:self];
    }
    
    if(self.hasClicked == NO) {
        self.hasClicked = YES;
        ADXDebugLog(@"trackClickURLs: %@", self.adData.trackClickURLs);
        if([self.adData.trackClickURLs count] <= 0 ) { return; }
        for (NSString *string in self.adData.trackClickURLs) {
            [ADXHTTPNetworkSession GETStartTaskWithRequestURLString:string];
        }
    }
}

@end
