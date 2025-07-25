//
//  FeeCalculationRepository.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/8/25.
//

import Foundation

enum FeeCalculationRepositoryError: Error {
    case calculationFailed(error: FeeCalculatorError)
    case unknown
}

final class FeeCalculationRepository {
    private let feeCalculator: FeeCalculatorProtocol
    private let storage: CalculationResultStorageProtocol
    
    init(
        feeCalculator: FeeCalculatorProtocol,
        storage: CalculationResultStorageProtocol
    ) {
        self.feeCalculator = feeCalculator
        self.storage = storage
    }
}

// MARK: - FeeCalculationRepositoryProtocol Conformation
extension FeeCalculationRepository: FeeCalculationRepositoryProtocol {
    func calculateFee(totalPrice: UInt, boxesCount: Int, mode: DividingMode) async throws(FeeCalculationRepositoryError) -> FeeCombination {
        if let cached = await storage.readCachedFeeCombination(totalPrice: totalPrice, boxesCount: boxesCount, mode: mode) {
            return cached
        }
        
        do {
            let combination = try await feeCalculator.calculate(totalPrice: totalPrice, count: boxesCount, mode: mode)
            await storage.createFeeCombinationCache(totalPrice: totalPrice, boxesCount: boxesCount, mode: mode, combination)
            return combination
        } catch let error as FeeCalculatorError {
            throw .calculationFailed(error: error)
        } catch {
            throw .unknown
        }
    }
}
