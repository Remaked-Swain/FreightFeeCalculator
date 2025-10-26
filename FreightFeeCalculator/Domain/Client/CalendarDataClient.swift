//
//  CalendarDataClient.swift
//  FreightFeeCalculator
//
//  Created by SwainYun on 10/25/25.
//

import Foundation
import Dependencies

private final actor LiveCalendarDataSource {
    private var monthsCache: [String: Month] = [:]
    
    @Dependency(\.dateClient) var dateClient
    
    func readMonth(_ date: Date) async throws(CalendarError) -> Month {
        let monthKey = await dateClient.monthKey(date)
        guard let month = monthsCache[monthKey] else { throw .dataNotFound(monthKey) }
        return month
    }
    
    func saveMonth(_ month: Month) async {
        let monthKey = await dateClient.monthKey(month.startDate)
        monthsCache[monthKey] = month
    }
    
    func deleteMonth(_ date: Date) async throws(CalendarError) {
        let monthKey = await dateClient.monthKey(date)
        guard monthsCache.removeValue(forKey: monthKey) != nil else { throw .dataNotFound(monthKey) }
    }
    
    func readDay(_ date: Date) async throws(CalendarError) -> Day {
        async let monthKey = dateClient.monthKey(date)
        async let dayKey = dateClient.dayKey(date)
        
        guard let month = await monthsCache[monthKey],
              let day = month.day(forKey: await dayKey)
        else { throw .dataNotFound(await dayKey) }
        return day
    }
    
    func saveDay(_ day: Day) async throws(CalendarError) {
        async let monthKey = dateClient.monthKey(day.date)
        async let dayKey = dateClient.dayKey(day.date)
        
        guard let existingMonth = await monthsCache[monthKey] else { throw .dataNotFound(await monthKey) }
        var daysDict = [String: Day]()
        
        await withTaskGroup(of: (String, Day).self) { group in
            for day in existingMonth.days {
                group.addTask { [dateClient] in
                    let key = await dateClient.dayKey(day.date)
                    return (key, day)
                }
            }
            
            for await (key, day) in group {
                daysDict[key] = day
            }
        }
        
        daysDict[await dayKey] = day
        let updatedMonth = Month(existingMonth.id, daysDict, existingMonth.startDate, existingMonth.savedPay, existingMonth.savedRate)
        monthsCache[await monthKey] = updatedMonth
    }
}

/// 캘린더 데이터의 영속성을 관리하는 클라이언트
struct CalendarDataClient {
    var readMonth: @Sendable (Date) async throws -> Month
    var saveMonth: @Sendable (Month) async throws -> Void
    var deleteMonth: @Sendable (Date) async throws -> Void
    var readDay: @Sendable (Date) async throws -> Day
    var saveDay: @Sendable (Day) async throws -> Void
}


// MARK: - DependencyKey
extension CalendarDataClient: DependencyKey {
    private static let dataSource = LiveCalendarDataSource()
    
    static var liveValue: CalendarDataClient = .init { date in
        try await dataSource.readMonth(date)
    } saveMonth: { month in
        await dataSource.saveMonth(month)
    } deleteMonth: { date in
        try await dataSource.deleteMonth(date)
    } readDay: { date in
        try await dataSource.readDay(date)
    } saveDay: { day in
        try await dataSource.saveDay(day)
    }
}

// MARK: - DependencyValues
extension DependencyValues {
    var calendarDataClient: CalendarDataClient {
        get { self[CalendarDataClient.self] }
        set { self[CalendarDataClient.self] = newValue }
    }
}
