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
    
    private func makeKey(
        _ totalPrice: UInt,
        _ totalCount: Int,
        _ packageGroups: [PackageGroup],
        _ shippingType: ShippingType,
        _ mode: DividingMode
    ) -> Key {
        let groupsKey = packageGroups.map { "\($0.type.rawValue):\($0.count)" }.joined(separator: "-")
        return "\(totalPrice)-\(totalCount)-\(groupsKey)-\(shippingType)-\(mode)"
    }
    
    func create(
        _ totalPrice: UInt,
        _ totalCount: Int,
        _ packageGroups: [PackageGroup],
        _ shippingType: ShippingType,
        _ mode: DividingMode,
        _ combinations: [FeeCombination]
    ) {
        let key = makeKey(totalPrice, totalCount, packageGroups, shippingType, mode)
        cache[key] = combinations
        print("계산결과 캐시 저장: \(key)")
    }
    
    func read(
        _ totalPrice: UInt,
        _ totalCount: Int,
        _ packageGroups: [PackageGroup],
        _ shippingType: ShippingType,
        _ mode: DividingMode
    ) -> [FeeCombination]? {
        let key = makeKey(totalPrice, totalCount, packageGroups, shippingType, mode)
        print("계산결과 캐시 조회: \(key)")
        return cache[key]
    }
    
    func delete(
        _ totalPrice: UInt,
        _ totalCount: Int,
        _ packageGroups: [PackageGroup],
        _ shippingType: ShippingType,
        _ mode: DividingMode
    ) {
        let key = makeKey(totalPrice, totalCount, packageGroups, shippingType, mode)
        cache.removeValue(forKey: key)
        print("계산결과 캐시 삭제: \(key)")
    }
}

/// 화물 포장 조합 계산을 위한 클라이언트
struct FeeCalculatorClient {
    var calculateFee: @Sendable (UInt, Int, [PackageGroup], ShippingType, DividingMode) async throws -> [FeeCombination]
}

// MARK: - DependencyKey
extension FeeCalculatorClient: DependencyKey {
    private static func calculate(
        totalPrice: UInt,
        totalCount: Int,
        packageGroups: [PackageGroup],
        shippingType: ShippingType,
        mode: DividingMode
    ) throws -> [FeeCombination] {
        guard totalCount > .zero, totalPrice > .zero else { throw FeeCalculatorError.invalidInput }
        let divisionUnit = mode.value
        
        guard totalPrice % divisionUnit == .zero else { throw FeeCalculatorError.roundingError }
        let targetSum = totalPrice / divisionUnit
        let baseFee = ShippingPolicy.baseFee(for: shippingType)
        let absoluteMinFee: UInt = 3000
        
        guard absoluteMinFee >= divisionUnit, absoluteMinFee % divisionUnit == .zero else { throw FeeCalculatorError.minFeeError }
        let startValue = absoluteMinFee / divisionUnit
        
        guard targetSum >= (UInt(totalCount) * startValue) else { throw FeeCalculatorError.invalidInput }
        var allPartitions: [[UInt]] = []
        findPartitions(remainingSum: targetSum, remainingCount: totalCount, startValue: startValue, currentPartition: [], results: &allPartitions)
        let combinations = allPartitions.map { partition in
            let fees = partition.map { $0 * divisionUnit }
            return FeeCombination(fees: fees)
        }
        let groupCounts = packageGroups.map { $0.count }.sorted(by: >)
        let sortedCombinations = combinations.sorted {
            let scoreA = calculateMatchScore(combination: $0, groupCounts: groupCounts, baseFee: baseFee)
            let scoreB = calculateMatchScore(combination: $1, groupCounts: groupCounts, baseFee: baseFee)
            guard scoreA == scoreB else { return scoreA > scoreB }
            return $0.fees.keys.count < $1.fees.keys.count
        }
        
        return sortedCombinations
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
    
    private static func calculateMatchScore(combination: FeeCombination, groupCounts: [Int], baseFee: UInt) -> Int {
        var score: Int = .zero
        let combinationCounts = combination.fees.values.sorted(by: >)
        if combinationCounts == groupCounts { score += 100 }
        let allComplyToBaseFee = combination.fees.keys.allSatisfy { $0 >= baseFee }
        if allComplyToBaseFee { score += 10 }
        return score
    }
    
    private static let cache = LiveCacheStorage()
    
    static var liveValue: FeeCalculatorClient = .init { totalPrice, totalCount, packageGroups, shippingType, mode in
        if let cached = await cache.read(totalPrice, totalCount, packageGroups, shippingType, mode) { return cached }
        
        do {
            let combinations = try Self.calculate(totalPrice: totalPrice, totalCount: totalCount, packageGroups: packageGroups, shippingType: shippingType, mode: mode)
            await cache.create(totalPrice, totalCount, packageGroups, shippingType, mode, combinations)
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
