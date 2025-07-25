//
//  Date.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/17/25.
//

import Foundation

extension Date {
    var calendar: Calendar {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }
    
    var startOfDay: Date {
        calendar.startOfDay(for: self)
    }
}

// MARK: - Date + Format
extension Date {
    func toString(by dateFormat: DateFormat) async -> String {
        let formatter = await DateFormat.cachedFormatter(dateFormat: dateFormat)
        return formatter.string(from: self)
    }
    
    /// DateFormat에서 제공하는 형태와 다른 날짜 형식일 경우 사용
    func toString(by dateFormat: String) async -> String {
        let formatter = await DateFormat.cachedFormatter(dateFormat: dateFormat)
        return formatter.string(from: self)
    }
}

// MARK: - Date + Key
extension Date {
    func monthKey() async -> String {
        await toString(by: .yyyyMM)
    }
    
    func dayKey() async -> String {
        await toString(by: .yyyyMMdd)
    }
}
