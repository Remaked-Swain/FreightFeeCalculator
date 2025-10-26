//
//  FeeCalculatorClient.swift
//  FreightFeeCalculator
//
//  Created by SwainYun on 10/24/25.
//

import Foundation
import Dependencies

private final actor LiveCacheStorage {
    typealias Key = String
    
    private var cache: [Key: [FeeCombination]] = [:]
    
    private func makeKey(totalPrice: UInt, boxesCount: Int, mode: DividingMode) -> Key {
        "\(totalPrice)-\(boxesCount)-\(mode)"
    }
    
    func create(totalPrice: UInt, boxesCount: Int, mode: DividingMode, _ combinations: [FeeCombination]) {
        let key = makeKey(totalPrice: totalPrice, boxesCount: boxesCount, mode: mode)
        cache[key] = combinations
        print("계산결과 캐시 저장: \(key)")
    }
    
    func read(totalPrice: UInt, boxesCount: Int, mode: DividingMode) -> [FeeCombination]? {
        let key = makeKey(totalPrice: totalPrice, boxesCount: boxesCount, mode: mode)
        print("계산결과 캐시 조회: \(key)")
        return cache[key]
    }
    
    func delete(totalPrice: UInt, boxesCount: Int, mode: DividingMode) {
        let key = makeKey(totalPrice: totalPrice, boxesCount: boxesCount, mode: mode)
        cache.removeValue(forKey: key)
        print("계산결과 캐시 삭제: \(key)")
    }
}

/// 화물 포장 조합 계산을 위한 클라이언트
struct FeeCalculatorClient {
    var calculateFee: @Sendable (UInt, Int, DividingMode) async throws -> [FeeCombination]
}

// MARK: - DependencyKey
extension FeeCalculatorClient: DependencyKey {
    private static func calculate(totalPrice: UInt, boxesCount: Int, mode: DividingMode) throws -> [FeeCombination] {
        guard boxesCount > .zero, totalPrice > .zero else { throw FeeCalculatorError.invalidInput }
        let divisionUnit = mode.value
        
        guard totalPrice % divisionUnit == .zero else { throw FeeCalculatorError.roundingError }
        let targetSum = totalPrice / divisionUnit
        let count = boxesCount
        
        guard targetSum >= UInt(count) else { throw FeeCalculatorError.invalidInput }
        var allPartitions: [[UInt]] = []
        findPartitions(remainingSum: targetSum, remainingCount: count, startValue: 1, currentPartition: [], results: &allPartitions)
        return allPartitions.map { partition in
            let fees = partition.map { $0 * divisionUnit }
            return FeeCombination(fees: fees)
        }
    }
    
    /// 정수 분할을 찾는 재귀 함수
    ///
    /// - Parameters:
    ///     - remainingSum: 남은 합계 (예: 11)
    ///     - remainingCount: 채워야 할 분할 수 (예: 3)
    ///     - startValue: 중복 조합을 피하기 위한 시작 값 (예: [1, 2, ...] 다음 [2, 1, ...] 방지)
    ///     - currentPartition: 현재까지의 조합 (예: [3])
    ///     - results: 결과를 저장할 배열 (예: [[3, 4, 4], [3, 3, 5], ...])
    private static func findPartitions(remainingSum: UInt, remainingCount: Int, startValue: UInt, currentPartition: [UInt], results: inout [[UInt]]) {
        if remainingCount == 1 {
            if remainingSum >= startValue {
                results.append(currentPartition + [remainingSum])
            }
            return
        }
        
        let maxPossibleValue = remainingSum / UInt(remainingCount)
        
        for i in startValue...maxPossibleValue {
            findPartitions(remainingSum: remainingSum - i, remainingCount: remainingCount - 1, startValue: i, currentPartition: currentPartition + [i], results: &results)
        }
    }
    
    private static let cache = LiveCacheStorage()
    
    static var liveValue: FeeCalculatorClient = .init { totalPrice, boxesCount, mode in
        if let cached = await cache.read(totalPrice: totalPrice, boxesCount: boxesCount, mode: mode) { return cached }
        
        do {
            let combinations = try Self.calculate(totalPrice: totalPrice, boxesCount: boxesCount, mode: mode)
            await cache.create(totalPrice: totalPrice, boxesCount: boxesCount, mode: mode, combinations)
            return combinations
        } catch let error as FeeCalculatorError {
            throw error
        }
    }
}

// MARK: - DependencyValues
extension DependencyValues {
    var feeCalculationClient: FeeCalculatorClient {
        get { self[FeeCalculatorClient.self] }
        set { self[FeeCalculatorClient.self] = newValue }
    }
}
