//
//  CalculationResultStorageProtocol.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/8/25.
//

import Foundation

protocol CalculationResultStorageProtocol {
    func createFeeCombinationCache(totalPrice: UInt, boxesCount: Int, mode: DividingMode, _ combination: FeeCombination) async
    func readCachedFeeCombination(totalPrice: UInt, boxesCount: Int, mode: DividingMode) async -> FeeCombination?
    func deleteCachedFeeCombination(totalPrice: UInt, boxesCount: Int, mode: DividingMode) async
}
