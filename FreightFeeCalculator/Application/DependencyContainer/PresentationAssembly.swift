//
//  PresentationAssembly.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/19/25.
//

import Swinject

struct PresentationAssembly: @preconcurrency Assembly {
    @MainActor
    func assemble(container: Container) {
        container.register(FeeCombinationViewModel.self) { resolver in
            guard let calculateFreightFeeUseCase = resolver.resolve(CalculateFreightFeeUseCaseProtocol.self) else {
                fatalError("Missing Dependency: CalculateFreightFeeUseCaseProtocol")
            }
            return FeeCombinationViewModel(calculateFreightFeeUseCase)
        }
        
        container.register(CalendarViewModel.self) { resolver in
            guard let calendarUseCase = resolver.resolve(CalendarUseCaseProtocol.self),
                  let calculateSalaryUseCase = resolver.resolve(CalculateSalaryUseCaseProtocol.self),
                  let manageWorkStatusUseCase = resolver.resolve(ManageWorkStatusUseCaseProtocol.self) else {
                fatalError("Missing Dependency: CalendarUseCaseProtocol, CalculateSalaryUseCaseProtocol, ManageWorkStatusUseCaseProtocol")
            }
            return CalendarViewModel(
                calendarUseCase: calendarUseCase,
                calculateSalaryUseCase: calculateSalaryUseCase,
                manageWorkStatusUseCase: manageWorkStatusUseCase
            )
        }
    }
}
