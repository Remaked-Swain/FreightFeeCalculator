//
//  InfrastructureAssembly.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/19/25.
//

import Foundation
import Swinject

struct InfrastructureAssembly: Assembly {
    func assemble(container: Container) {
        container.register(FeeCalculatorProtocol.self) { _ in
            FeeCalculator()
        }
        .inObjectScope(.container)
        
        container.register(CalculationResultStorageProtocol.self) { _ in
            CalculationResultStorage()
        }
        .inObjectScope(.container)
    }
}
