//
//  ADXGdprConstants.h
//  ADXLibrary
//
//  Copyright © 2017 AD(X) Corp. All rights reserved.
//

// GDPR 호출 타입
typedef NS_ENUM(NSInteger, ADXGdprType) {
    ADXGdprTypePopupLocation     = 10, // 위치에 따라 동의 팝업 표출
    ADXGdprTypePopupDebug        = 11, // 동의 팝업 표출 (기존 debug 처리)
    ADXGdprTypeDirectUnknown     = 0,  // 매체에서 직접 처리 (ADXConsentStateUnknown)
    ADXGdprTypeDirectNotRequired = 1,  // 매체에서 직접 처리 (ADXConsentStateNotRequired)
    ADXGdprTypeDirectDenied      = 2,  // 매체에서 직접 처리 (ADXConsentStateDenied)
    ADXGdprTypeDirectConfirm     = 3   // 매체에서 직접 처리 (ADXConsentStateConfirm)
};

// GDPR 동의 결과
typedef NS_ENUM(NSInteger, ADXConsentState) {
    ADXConsentStateUnknown       = 0, // 동의 여부가 존재하지 않는 사용자
    ADXConsentStateNotRequired   = 1, // 동의 여부가 필요 없는 지역 (EU 외 지역)
    ADXConsentStateDenied        = 2, // 사용자가 개인정보 활용 및 수집을 거부한 상태
    ADXConsentStateConfirm       = 3  // 사용자가 개인정보 활용 및 수집을 동의한 상태
};

typedef NS_ENUM(NSInteger, ADXLocate) {
    ADXLocateInEEAorUnknown      = 0,
    ADXLocateNotEEA              = 1,
    ADXLocateCheckFail           = 2
};
