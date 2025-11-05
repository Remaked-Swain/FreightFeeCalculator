//
//  DomainErrors.swift
//  FreightFeeCalculator
//
//  Created by SwainYun on 10/25/25.
//

import Foundation

enum FeeCalculatorError: Error {
    /// 유효하지 않은 입력 (예: 박스 개수가 0 이하이거나 총 운임비가 계산 불가능한 수)
    case invalidInput
    /// 계산 실패
    case calculationFailed
    /// 분배 단위로 정확히 반올림/내림할 수 없는 경우
    case roundingError
    /// 오버플로우 발생
    case overflowError
    /// 기본운임과 맞지 않음
    case baseFeeError
    /// 최소운임과 맞지 않음
    case minFeeError
    case unknown
}

enum CalendarError: Error {
    case invalidDate
    case dataNotFound(String)
}

enum ManageWorkStatusError: Error {
    case invalidDay
}
