//
//  AdPieAdData.m
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import "AdPieAdData.h"
#import <ADXLibrary/ADXConfiguration.h>
#import <ADXLibrary/ADXAdLogEvent.h>

@implementation AdPieAdData

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super initWithDictionary:dictionary]) {
        _icType = (AdPieAdContentType)[self integerForKey:@"ictype"];
        _adm = [self stringForKey:@"adm"];
        _admImageTag = [self stringForKey:@"adm_img_tag"];
        _width = [self intForKey:@"width"];
        _height = [self intForKey:@"height"];
        _bgColor = [self stringForKey:@"bgcolor"];
        _position = [self intForKey:@"position"];
        _animationType = [self intForKey:@"animation"];
        _monitoring = [self intForKey:@"act"];
        _trackImpressionURLs = [self arrayForKey:@"imptrackers"];
        _trackClickURLs = [self arrayForKey:@"clicktrackers"];
        _webViewLanding = [self intForKey:@"wv_clk_v2"];
        _orientation = [self intForKey:@"orientation"];
        ADXLogInfo(@"Original Orientaion: %d", _orientation);
        
        UIInterfaceOrientationMask orientations = [ADXConfiguration plistSupportedOrientations];
        // 세로 방향이 설정되어 있지 않다면, Landscape으로 설정
        if(!(orientations & UIInterfaceOrientationMaskPortrait)){
            ADXLogInfo(@"No Support Portrait");
            _orientation = AdPieAdOrientationLandscape;
            ADXLogInfo(@"Orientaion changed#1: %d", _orientation);
        }
        
        // 가로방향 (좌/우측) 모두 설정되어 있지 않다면, Portrait으로 설정
        ADXLogInfo(@"Is LandscapeLeft supported ? (%@)", (orientations & UIInterfaceOrientationMaskLandscapeLeft)? @"YES":@"NO");
        ADXLogInfo(@"Is LandscapeRight supported ? (%@)", (orientations & UIInterfaceOrientationMaskLandscapeRight)? @"YES":@"NO");
        ADXLogInfo(@"Is Portrait supported ? (%@)", (orientations & UIInterfaceOrientationMaskPortrait)? @"YES":@"NO");
        ADXLogInfo(@"Is PortraitUpsideDown supported ? (%@)", (orientations & UIInterfaceOrientationMaskPortraitUpsideDown)? @"YES":@"NO");
        if(!(orientations & UIInterfaceOrientationMaskLandscapeLeft) &&
           !(orientations & UIInterfaceOrientationMaskLandscapeRight))
        {
            ADXLogInfo(@"No Support Landscape");
            _orientation = AdPieAdOrientationPortrait;
            ADXLogInfo(@"Orientaion changed#2: %d", _orientation);
        }
        
        _closeButtonPostion = [self intForKey:@"xposition"];
        
        _closeButtonDelay = [self longForKey:@"cbd"];
        ADXLogInfo(@"_closeButtonDelay: %d", _closeButtonDelay);
        if(_closeButtonDelay > 0) {
            // 단위 변경 (ms -> seconds)
            _closeButtonDelay = MIN(_closeButtonDelay, 6000); // 최대시간 60초
            _closeButtonDelay = _closeButtonDelay / 1000;
        }
        
        // iOS에서는 사용하지 않는 값
        _webviewLoadingSkip = [self intForKey:@"wvls"];
    }
    
    return self;
}
@end
