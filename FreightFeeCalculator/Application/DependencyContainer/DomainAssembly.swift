//
//  DomainAssembly.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/19/25.
//

import Foundation
import Swinject

struct DomainAssembly: Assembly {
    func assemble(container: Container) {
        let calendar: Calendar = {
            var calendar = Calendar.current
            calendar.locale = Locale(identifier: "ko_KR")
            if let timeZone = TimeZone(identifier: "UTC") {
                calendar.timeZone = timeZone
            }
            return calendar
        }()
        
        container.register(CalculateFreightFeeUseCaseProtocol.self) { resolver in
            guard let feeCalculationRepository = resolver.resolve(FeeCalculationRepositoryProtocol.self) else {
                fatalError("Missing Dependency: FeeCalculationRepositoryProtocol")
            }
            return CalculateFreightFeeUseCase(repository: feeCalculationRepository)
        }
        .inObjectScope(.container)
        
        container.register(CalculateSalaryUseCaseProtocol.self) { _ in
            return CalculateSalaryUseCase()
        }
        .inObjectScope(.container)
        
        container.register(CalendarUseCaseProtocol.self) { resolver in
            guard let calendarDataSourceRepository = resolver.resolve(CalendarDataSourceRepositoryProtocol.self) else {
                fatalError("Missing Dependency: CalendarDataSourceRepositoryProtocol")
            }
            return CalendarUseCase(calendarDataSourceRepository: calendarDataSourceRepository, calendar: calendar)
        }
        .inObjectScope(.container)
        
        container.register(ManageWorkStatusUseCaseProtocol.self) { resolver in
            guard let calendarDataSourceRepository = resolver.resolve(CalendarDataSourceRepositoryProtocol.self) else {
                fatalError("Missing Dependency: CalendarDataSourceRepositoryProtocol")
            }
            return ManageWorkStatusUseCase(calendarDataSourceRepository: calendarDataSourceRepository)
        }
        .inObjectScope(.container)
    }
}
