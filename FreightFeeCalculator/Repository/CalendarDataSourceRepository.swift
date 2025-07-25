//
//  CalendarDataSourceRepository.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/18/25.
//

import Foundation

final actor CalendarDataSourceRepository {
    private var monthsCache: [String: Month] = [:]
}

// MARK: - CalendarDataSourceRepositoryProtocol Conformation
extension CalendarDataSourceRepository: CalendarDataSourceRepositoryProtocol {
    func readMonth(_ date: Date) async throws -> Month {
        let monthKey = await date.monthKey()
        guard let month = monthsCache[monthKey] else { throw RepositoryError.dataNotFound("Month data not found for date: \(monthKey)") }
        print("Read Month: \(monthKey)")
        return month
    }
    
    func saveMonth(_ month: Month) async throws {
        let monthKey = await month.startDate.monthKey()
        monthsCache[monthKey] = month
        print("Save Month: \(monthKey)")
    }
    
    func deleteMonth(_ date: Date) async throws {
        let monthKey = await date.monthKey()
        guard monthsCache.removeValue(forKey: monthKey) != nil else {
            throw RepositoryError.deleteFailed("Month data not found for deletion: \(monthKey)")
        }
        print("Delete Month: \(monthKey)")
    }
    
    func readDay(_ date: Date) async throws -> Day {
        async let monthKey = date.monthKey()
        async let dayKey = date.dayKey()
        guard let month = await monthsCache[monthKey],
              let day = await month.day(for: date)
        else { throw RepositoryError.dataNotFound("Day data not found for date:\(await dayKey)") }
        print("Read Day: \(await dayKey)")
        return day
    }
    
    func saveDay(_ day: Day) async throws {
        async let monthKey = day.date.monthKey()
        async let dayKey = day.date.dayKey()
        guard let existingMonth = await monthsCache[monthKey] else {
            throw RepositoryError.dataNotFound("Month date not found for save day")
        }
        
        var daysDict = [String: Day]()
        
        await withTaskGroup { group in
            for day in existingMonth.days {
                group.addTask {
                    let dayKey = await day.date.dayKey()
                    return (dayKey, day)
                }
            }
            
            for await (dayKey, day) in group {
                daysDict[dayKey] = day
            }
        }
        
        await daysDict[dayKey] = day
        let updatedMonth = Month(existingMonth.id, daysDict, existingMonth.startDate)
        await monthsCache[monthKey] = updatedMonth
        print("Save Day: \(await dayKey)")
    }
}
