//
//  ADXAdError.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const ADXAdErrorDomain;

typedef NS_ENUM(NSInteger, ADXAdErrorCode) {
    ADXAdErrorUnknown          = -1,     // 알 수 없는 오류
    ADXAdErrorTimeout          = -1001,  // Timeout
    ADXAdErrorNoFill           = 100,    // 광고 없음
    ADXAdErrorInvalidRequest   = 101,    // 잘못된 광고 요청
    ADXAdErrorNetwork          = 102,    // 네트워크 오류
    ADXAdErrorNoConnection     = 103,    // 인터넷 연결 오류
    ADXAdErrorInternal         = 104,    // SDK 내부 오류
    ADXAdErrorSdkNotInitialize = 105,    // SDK 초기화 미완료
    ADXAdErrorDuplicateRequest = 106,    // 중복 요청
    ADXAdErrorContentLoad      = 107,    // 컨텐츠 로딩 실패
    ADXAdErrorServerData       = 108,    // 서버 데이터 오류
    ADXAdErrorInvalidLayout    = 109,    // 레이아웃 설정 오류
    ADXAdErrorLimitRequest     = 110,    // 광고 요청의 시간 제한
    ADXAdErrorNoMediationData  = 111     // 미디에이션 정보 없음
};

@interface NSError (ADX)

+ (instancetype)errorWithCode:(ADXAdErrorCode)code;
+ (instancetype)errorWithCode:(NSInteger)code description:(NSString *)description;
+ (instancetype)errorWithDomain:(NSString *)domain code:(ADXAdErrorCode)code;
+ (instancetype)errorWithDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)description;

@end

NS_ASSUME_NONNULL_END
