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
    
    private var cache: [Key: FeeCombination] = [:]
    
    private func makeKey(totalPrice: UInt, boxesCount: Int, mode: DividingMode) -> Key {
        "\(totalPrice)-\(boxesCount)-\(mode)"
    }
    
    func create(totalPrice: UInt, boxesCount: Int, mode: DividingMode, _ combination: FeeCombination) {
        let key = makeKey(totalPrice: totalPrice, boxesCount: boxesCount, mode: mode)
        cache[key] = combination
        print("계산결과 캐시 저장: \(key)")
    }
    
    func read(totalPrice: UInt, boxesCount: Int, mode: DividingMode) -> FeeCombination? {
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
    var calculateFee: @Sendable (UInt, Int, DividingMode) async throws -> FeeCombination
}

// MARK: - DependencyKey
extension FeeCalculatorClient: DependencyKey {
    private static func calculate(totalPrice: UInt, boxesCount: Int, mode: DividingMode) throws -> FeeCombination {
        guard boxesCount > .zero, totalPrice > .zero else { throw FeeCalculatorError.invalidInput }
        let divisionUnit = mode.value
        let baseFee = totalPrice / UInt(boxesCount)
        
        guard baseFee >= divisionUnit else { throw FeeCalculatorError.roundingError }
        let roundedBaseFee = (baseFee / divisionUnit) * divisionUnit
        
        guard roundedBaseFee <= UInt.max / UInt(boxesCount) else { throw FeeCalculatorError.overflowError }
        let totalBaseAmmount = roundedBaseFee * UInt(boxesCount)
        
        guard totalBaseAmmount <= totalPrice else { throw FeeCalculatorError.calculationFailed }
        var remainer = totalPrice - totalBaseAmmount
        var fees = Array(repeating: roundedBaseFee, count: boxesCount)
        var index = 0
        
        while remainer >= divisionUnit, index < boxesCount {
            fees[index] += divisionUnit
            remainer -= divisionUnit
            index += 1
        }
        
        guard remainer == .zero else { throw FeeCalculatorError.calculationFailed }
        return FeeCombination(fees: fees)
    }
    
    private static let cache = LiveCacheStorage()
    
    static var liveValue: FeeCalculatorClient = .init { totalPrice, boxesCount, mode in
        if let cached = await cache.read(totalPrice: totalPrice, boxesCount: boxesCount, mode: mode) { return cached }
        
        do {
            let combination = try Self.calculate(totalPrice: totalPrice, boxesCount: boxesCount, mode: mode)
            await cache.create(totalPrice: totalPrice, boxesCount: boxesCount, mode: mode, combination)
            return combination
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
