//
//  CalculateFreightFeeUseCase.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/8/25.
//

import Foundation

protocol CalculateFreightFeeUseCaseProtocol {
    func execute(totalPrice: UInt, boxesCount: Int, mode: DividingMode) async throws -> FeeCombination
}

final class CalculateFreightFeeUseCase {
    private let repository: FeeCalculationRepositoryProtocol
    
    init(repository: FeeCalculationRepositoryProtocol = FeeCalculationRepository()) {
        self.repository = repository
    }
}

// MARK: - CalculateFreightFeeUseCaseProtocol Conformation
extension CalculateFreightFeeUseCase: CalculateFreightFeeUseCaseProtocol {
    func execute(totalPrice: UInt, boxesCount: Int, mode: DividingMode) async throws -> FeeCombination {
        try await repository.calculateFee(totalPrice: totalPrice, boxesCount: boxesCount, mode: mode)
    }
}
