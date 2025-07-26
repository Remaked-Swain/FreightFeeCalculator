//
//  CalendarUseCase.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/17/25.
//

import Foundation

protocol CalendarUseCaseProtocol {
    var totalDaysCount: Int { get }
    
    func generateInitialMonths(for date: Date) async throws -> [Month]
    func updateMonthsForPaging(with currentMonths: [Month], direction: CalendarPagingDirection) async throws -> [Month]
}

extension CalendarUseCaseProtocol {
    var totalDaysCount: Int { 7 * 6 }
}

enum CalendarError: Error, LocalizedError {
    case invalidDate
    case dataNotFound(String)
    case repositoryError(RepositoryError)
    
    var errorDescription: String? {
        switch self {
        case .invalidDate: return "유효하지 않은 날짜입니다."
        case .dataNotFound(let message): return message
        case .repositoryError(let error): return error.localizedDescription
        }
    }
}

enum CalendarPagingDirection {
    case previous, next
}

final class CalendarUseCase {
    private let calendarDataSourceRepository: CalendarDataSourceRepositoryProtocol
    private let calendar: Calendar
    
    init(
        calendarDataSourceRepository: CalendarDataSourceRepositoryProtocol,
        calendar: Calendar
    ) {
        self.calendarDataSourceRepository = calendarDataSourceRepository
        self.calendar = calendar
    }
    
    private func prepareMonth(_ date: Date) async throws -> Month {
        if let cachedMonth = try? await calendarDataSourceRepository.readMonth(date) {
            return cachedMonth
        }
        
        let newMonth = try await generateMonth(date)
        try await calendarDataSourceRepository.saveMonth(newMonth)
        return newMonth
    }
    
    private func generateMonth(_ date: Date) async throws -> Month {
        guard let startDateOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            throw CalendarError.invalidDate
        }
        
        let weekdayOfFirstDay = calendar.component(.weekday, from: startDateOfMonth)
        let numberOfDaysBeforeMonth = (weekdayOfFirstDay - calendar.firstWeekday + 7) % 7
        
        guard let gridStartDate = calendar.date(byAdding: .day, value: -numberOfDaysBeforeMonth, to: startDateOfMonth) else {
            throw CalendarError.invalidDate
        }
        
        var daysDict = [String: Day]()
        
        try await withThrowingTaskGroup { group in
            (0..<totalDaysCount).forEach { i in
                group.addTask { [calendar] in
                    guard let currentDate = calendar.date(byAdding: .day, value: i, to: gridStartDate) else {
                        throw CalendarError.invalidDate
                    }
                    
                    let numberOfDay = calendar.component(.day, from: currentDate)
                    let isValid = calendar.isDate(currentDate, equalTo: startDateOfMonth, toGranularity: .month)
                    let day = Day(UUID().uuidString, currentDate, numberOfDay, isValid: isValid)
                    return await (day.date.dayKey(), day)
                }
            }
            
            for try await result in group {
                let (dayKey, day) = result
                daysDict[dayKey] = day
            }
        }
        
        return Month(UUID(), daysDict, startDateOfMonth)
    }
}

// MARK: - CalendarUseCaseProtocol Conformation
extension CalendarUseCase: CalendarUseCaseProtocol {
    func generateInitialMonths(for date: Date) async throws -> [Month] {
        guard let previousMonthDate = calendar.date(byAdding: .month, value: -1, to: date),
              let nextMonthDate = calendar.date(byAdding: .month, value: 1, to: date)
        else { throw CalendarError.invalidDate }
        
        async let previous = try prepareMonth(previousMonthDate)
        async let current = try prepareMonth(date)
        async let next = try prepareMonth(nextMonthDate)
        return try await [previous, current, next]
    }
    
    func updateMonthsForPaging(with currentMonths: [Month], direction: CalendarPagingDirection) async throws -> [Month] {
        guard currentMonths.isEmpty == false, currentMonths.count == 3 else {
            throw CalendarError.dataNotFound("아직 달력이 구성되지 않았습니다.")
        }
        
        var newMonths: [Month]
        switch direction {
        case .previous:
            guard let newPreviousMonthDate = calendar.date(byAdding: .month, value: -1, to: currentMonths[0].startDate) else {
                throw CalendarError.invalidDate
            }
            let newPreviousMonth = try await prepareMonth(newPreviousMonthDate)
            newMonths = [newPreviousMonth, currentMonths[0], currentMonths[1]]
            
        case .next:
            guard let newCurrentMonthDate = calendar.date(byAdding: .month, value: 1, to: currentMonths[2].startDate) else {
                throw CalendarError.invalidDate
            }
            let newNextMonth = try await prepareMonth(newCurrentMonthDate)
            newMonths = [currentMonths[1], currentMonths[2], newNextMonth]
        }
        
        return newMonths
    }
}
