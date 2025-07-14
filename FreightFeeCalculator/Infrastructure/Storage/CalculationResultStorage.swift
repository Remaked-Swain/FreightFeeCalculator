//
//  CalculationResultStorage.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/8/25.
//

import Foundation

final actor CalculationResultStorage {
    typealias Key = String
    
    private var cache: [Key: FeeCombination] = [:]
    
    private func makeKey(totalPrice: UInt, boxesCount: Int, mode: DividingMode) -> Key {
        "\(totalPrice)-\(boxesCount)-\(mode)"
    }
}

// MARK: - CalculationResultStorageProtocol Conformation
extension CalculationResultStorage: CalculationResultStorageProtocol {
    func createFeeCombinationCache(totalPrice: UInt, boxesCount: Int, mode: DividingMode, _ combination: FeeCombination) async {
        let key = makeKey(totalPrice: totalPrice, boxesCount: boxesCount, mode: mode)
        cache[key] = combination
        print("계산결과 캐시 저장: \(key)")
    }
    
    func readCachedFeeCombination(totalPrice: UInt, boxesCount: Int, mode: DividingMode) async -> FeeCombination? {
        let key = makeKey(totalPrice: totalPrice, boxesCount: boxesCount, mode: mode)
        print("계산결과 캐시 조회: \(key)")
        return cache[key]
    }
    
    func deleteCachedFeeCombination(totalPrice: UInt, boxesCount: Int, mode: DividingMode) async {
        let key = makeKey(totalPrice: totalPrice, boxesCount: boxesCount, mode: mode)
        cache.removeValue(forKey: key)
        print("계산결과 캐시 삭제: \(key)")
    }
}
