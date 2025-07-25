//
//  ToggleWorkStatusUseCase.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/17/25.
//

import Foundation

protocol ManageWorkStatusUseCaseProtocol {
    /// 특정 날짜의 근무 여부를 변경
    /// - Parameters:
    ///     - day: 근무 상태를 변경할 Day 객체
    ///     - hours: 설정할 근무 시간
    /// - Returns: 변경된 Day 객체를 포함하는 Month 객체
    /// - Note: hours 매개변수로 `nil`이 전달되면 근무 상태를 해제함
    func execute(on day: Day, hours: WorkHours?) async throws -> Month
}

enum ManageWorkStatusError: Error {
    case invalidDay
}

final class ManageWorkStatusUseCase {
    private let calendarDataSourceRepository: CalendarDataSourceRepositoryProtocol
    
    init(calendarDataSourceRepository: CalendarDataSourceRepositoryProtocol) {
        self.calendarDataSourceRepository = calendarDataSourceRepository
    }
}

// MARK: - ManageWorkStatusUseCaseProtocol Conformation
extension ManageWorkStatusUseCase: ManageWorkStatusUseCaseProtocol {
    func execute(on day: Day, hours: WorkHours?) async throws -> Month {
        let targetDate = day.date
        var currentDay = try await calendarDataSourceRepository.readDay(targetDate)
        
        guard currentDay.isValid else { throw ManageWorkStatusError.invalidDay }
        
        if currentDay.hasWorked {
            if currentDay.workHours == hours {
                currentDay.workHours = nil
            } else {
                currentDay.workHours = hours
            }
        } else {
            currentDay.workHours = hours
        }
        
        try await calendarDataSourceRepository.saveDay(currentDay)
        return try await calendarDataSourceRepository.readMonth(targetDate)
    }
}
