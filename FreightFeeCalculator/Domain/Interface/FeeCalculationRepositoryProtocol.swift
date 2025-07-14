//
//  FeeCalculationRepositoryProtocol.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/8/25.
//

import Foundation

protocol FeeCalculationRepositoryProtocol {
    func calculateFee(totalPrice: UInt, boxesCount: Int, mode: DividingMode) async throws -> FeeCombination
}
