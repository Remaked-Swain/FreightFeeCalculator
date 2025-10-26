//
//  SalaryCalculatorClient.swift
//  FreightFeeCalculator
//
//  Created by SwainYun on 10/24/25.
//

import Foundation
import Dependencies

/// 급여 계산 비즈니스 로직을 수행하는 클라이언트
struct SalaryCalculatorClient {
    var calculate: @Sendable (Month, Double) -> Double
}

// MARK: - DependencyKey
extension SalaryCalculatorClient: DependencyKey {
    static var liveValue: SalaryCalculatorClient = .init { month, rate in
        let totalHours = month.days.reduce(Double.zero) { sum, day in
            guard day.hasWorked, let hours = day.workHours else { return sum }
            return sum + Double(hours.value)
        }
        return totalHours * rate
    }
    
    static let testValue: SalaryCalculatorClient = .init { _, _ in 500000.0 }
}

// MARK: - DependencyValues
extension DependencyValues {
    var salaryCalculatorClient: SalaryCalculatorClient {
        get{ self[SalaryCalculatorClient.self] }
        set { self[SalaryCalculatorClient.self] = newValue }
    }
}
