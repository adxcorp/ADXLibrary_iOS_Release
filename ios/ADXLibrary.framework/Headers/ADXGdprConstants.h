//
//  ADXGdprConstants.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

// GDPR 호출 타입
typedef NS_ENUM(NSInteger, ADXGdprType) {
    ADXGdprTypePopupLocation     = 10, // 지역에 따라 동의 팝업 호출 (EU 지역). GDPR 동의 화면 제공
    ADXGdprTypePopupDebug        = 11, // 지역 상관없이 동의 팝업 호출 테스트 (DEBUG). GDPR 동의 화면 제공
    ADXGdprTypeDirectUnknown     = 0,  // Unknown
    ADXGdprTypeDirectNotRequired = 1,  // 동의 여부가 필요없는 지역 (EU 외 지역). GDPR 관련 직접 동의 여부 설정
    ADXGdprTypeDirectDenied      = 2,  // 사용자가 개인정보 활용 및 수집 거부. GDPR 관련 직접 동의 여부 설정
    ADXGdprTypeDirectConfirm     = 3   // 사용자가 개인정보 활용 및 수집 동의. GDPR 관련 직접 동의 여부 설정
};

// GDPR 동의 결과
typedef NS_ENUM(NSInteger, ADXConsentState) {
    ADXConsentStateUnknown       = 0,  // 동의 여부가 존재하지 않는 사용자. 개인화 광고 미노출
    ADXConsentStateNotRequired   = 1,  // 동의 여부가 필요 없는 지역 (EU 외 지역). 개인화 광고 노출
    ADXConsentStateDenied        = 2,  // 사용자가 개인정보 활용 및 수집을 거부한 상태. 개인화 광고 미노출
    ADXConsentStateConfirm       = 3   // 사용자가 개인정보 활용 및 수집을 동의한 상태. 개인화 광고 노출
};

typedef NS_ENUM(NSInteger, ADXLocate) {
    ADXLocateInEEA               = 0,
    ADXLocateNotEEA              = 1,
    ADXLocateCheckFail           = 2
};
