//
//  CalculateSalaryUseCase.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/17/25.
//

import Foundation

protocol CalculateSalaryUseCaseProtocol {
    typealias Salary = Double
    
    /// 특정 월의 급여 계산
    /// - Parameters:
    ///     - for: 특정 월
    ///     - rate: 시간당 급여
    func execute(for month: Month, rate: Salary) async throws -> Salary
}

final class CalculateSalaryUseCase {
    
}

// MARK: - CalculateSalaryUseCaseProtocol Conformation
extension CalculateSalaryUseCase: CalculateSalaryUseCaseProtocol {
    func execute(for month: Month, rate: Salary) async throws -> Salary {
        let totalHours = month.days.reduce(0) { sum, day in
            guard day.hasWorked, let hours = day.workHours else { return sum }
            return sum + hours.value
        }
        return Double(totalHours) * rate
    }
}
