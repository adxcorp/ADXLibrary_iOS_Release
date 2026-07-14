//
//  ADXTnkUtil.m
//  ADXLibrary-Tnk
//
//  Created by JCLEE on 2023/02/10.
//

#import "ADXTnkUtil.h"

@implementation ADXTnkUtil

+ (UIViewController*)getRootViewController {
    
    UIViewController *rootViewController = nil;
    
    if (@available(iOS 13.0, *)) {
        // iOS 13 이상 프로젝트라도 UIWindowSceneDelegate를 사용하지 않는 프로젝트 경우 nil이 될 수 있음
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (![scene.delegate conformsToProtocol:@protocol(UIWindowSceneDelegate)]) { continue; }
            UIWindow *window = [(id<UIWindowSceneDelegate>)scene.delegate window];
            rootViewController = [window rootViewController];
            if(rootViewController){
                while ([rootViewController presentedViewController]) {
                    rootViewController = [rootViewController presentedViewController];
                }
            }
            if(rootViewController){
                break;
            }
        }
        
        // rootViewController가 nil이 아닌 경우 리턴
        if(rootViewController){
            return rootViewController;
        }
    }
    
    // rootViewController이 nil 경우, 이전 방식으로 rootViewController를 가져온다
    rootViewController = (UIViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    if(rootViewController){
        while ([rootViewController presentedViewController]) {
            rootViewController = [rootViewController presentedViewController];
        }
    }
    return rootViewController;
}

@end

