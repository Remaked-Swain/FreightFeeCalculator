//
//  RepositoryAssembly.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/19/25.
//

import Foundation
import Swinject

struct RepositoryAssembly: Assembly {
    func assemble(container: Container) {
        container.register(FeeCalculationRepositoryProtocol.self) { resolver in
            guard let feeCalculator = resolver.resolve(FeeCalculatorProtocol.self),
                  let calculationResultStorage = resolver.resolve(CalculationResultStorageProtocol.self)
            else {
                fatalError("Missing Dependency: FeeCalculatorProtocol")
            }
            return FeeCalculationRepository(
                feeCalculator: feeCalculator,
                storage: calculationResultStorage
            )
        }
        .inObjectScope(.container)
        
        container.register(CalendarDataSourceRepositoryProtocol.self) { _ in
            return CalendarDataSourceRepository()
        }
        .inObjectScope(.container)
    }
}
