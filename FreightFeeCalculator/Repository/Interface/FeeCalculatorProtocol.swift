//
//  FeeCalculatorProtocol.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/8/25.
//

import Foundation

protocol FeeCalculatorProtocol {
    /// 총 운임비, 박스 개수, 분배모드를 바탕으로 운임비 조합을 계산합니다.
    ///
    /// - Parameters:
    ///     - totalPrice: 총 운임비
    ///     - count: 박스 개수
    ///     - mode: 운임비 분배모드
    /// - Returns: 계산된 운임비 조합
    /// - Throws: 계산 과정 중 발생한 오류
    func calculate(totalPrice: UInt, count: Int, mode: DividingMode) async throws -> FeeCombination
}
