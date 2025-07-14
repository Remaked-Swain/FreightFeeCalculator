//
//  FeeCombinationViewModel.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/9/25.
//

import Foundation

@Observable @MainActor
final class FeeCombinationViewModel {
    private(set) var errorMessage: String?
    private(set) var calculateResult: [String] = []
    var total: String = String()
    var count: String = String()
    var mode: DividingMode = .byHundreds
    private var task: Task<Void, Never>?
    
    private let calculateFreightFeeUseCase: CalculateFreightFeeUseCaseProtocol
    
    init(_ calculateFreightFeeUseCase: CalculateFreightFeeUseCaseProtocol = CalculateFreightFeeUseCase()) {
        self.calculateFreightFeeUseCase = calculateFreightFeeUseCase
    }
    
    private func performResult(_ combination: FeeCombination) {
        let sorted = combination.fees.sorted {
            guard $0.value != $1.value else { return $0.key < $1.key }
            return $0.value > $1.value
        }
        
        calculateResult = sorted.map { "\($0.key.formatted(.currency(code: "KRW"))) x \($0.value)" }
    }
}

// MARK: - Interfaces
extension FeeCombinationViewModel {
    func calculate() async {
        task?.cancel()
        
        errorMessage = nil
        calculateResult.removeAll()
        
        task = Task {
            guard let total = UInt(total), let count = Int(count),
                  total > 0, count > 0
            else { return errorMessage = "잘못된 값 입력됨" }
            
            do {
                let feeCombination = try await calculateFreightFeeUseCase.execute(totalPrice: total, boxesCount: count, mode: mode)
                errorMessage = nil
                performResult(feeCombination)
            } catch let error as FeeCalculationRepositoryError {
                switch error {
                case .calculationFailed(let error):
                    switch error {
                    case .invalidInput: errorMessage = "잘못된 값 입력됨:\n\(error)"
                    case .calculationFailed, .roundingError: errorMessage = "계산 실패:\n\(error)"
                    case .overflowError: errorMessage = "오버플로우 발생:\n\(error)"
                    }
                case .unknown: errorMessage = "알 수 없는 에러"
                }
            } catch {
                errorMessage = "Error Occured\n\(error.localizedDescription)"
            }
            
            task = nil
        }
    }
}
