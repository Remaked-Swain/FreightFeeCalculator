//
//  FeeCalculator.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/8/25.
//

import Foundation

enum FeeCalculatorError: Error {
    /// 유효하지 않은 입력  (예: 박스 개수가 0 이하이거나 총 운임비가 계산 불가능한 수)
    case invalidInput
    /// 계산 실패
    case calculationFailed
    /// 분배 단위로 정확히 반올림/내림할 수 없는 경우
    case roundingError
    /// 오버플로우 발생
    case overflowError
}

final class FeeCalculator {
    
}

// MARK: - FeeCalculatorProtocol Conformation
extension FeeCalculator: FeeCalculatorProtocol {
    func calculate(totalPrice: UInt, count: Int, mode: DividingMode) async throws(FeeCalculatorError) -> FeeCombination {
        guard count > .zero, totalPrice > .zero else { throw .invalidInput }
        
        let divisionUnit = mode.value
        
        guard totalPrice <= UInt.max / UInt(count) else { throw .overflowError }
        
        let baseFee = totalPrice / UInt(count)
        
        guard baseFee >= divisionUnit else { throw .roundingError }
        
        let roundedBaseFee = (baseFee / divisionUnit) * divisionUnit
        let totalBaseAmmount = roundedBaseFee * UInt(count)
        
        guard totalBaseAmmount <= totalPrice else { throw .calculationFailed }
        
        var remainder = totalPrice - totalBaseAmmount
        var fees = Array(repeating: roundedBaseFee, count: count)
        var index = 0
        while remainder >= divisionUnit, index < count {
            fees[index] += divisionUnit
            remainder -= divisionUnit
            index += 1
        }
        
        guard fees.reduce(0, +) == totalPrice else { throw .calculationFailed }
        return FeeCombination(fees: fees)
    }
}
