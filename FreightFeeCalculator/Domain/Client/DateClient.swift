//
//  DateClient.swift
//  FreightFeeCalculator
//
//  Created by SwainYun on 10/25/25.
//

import Foundation
import Dependencies

private final actor DateFormatterCached {
    private var cached = [String: DateFormatter]()
    
    @Dependency(\.calendar) var calendar
    @Dependency(\.locale) var locale
    @Dependency(\.timeZone) var timeZone
    
    private func createFormatter(for dateFormat: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.calendar = calendar
        formatter.locale = locale
        formatter.timeZone = timeZone
        return formatter
    }
    
    func cachedFormatter(for dateFormat: String) -> DateFormatter {
        if let cached = cached[dateFormat] { return cached }
        let formatter = createFormatter(for: dateFormat)
        return formatter
    }
    
    func cachedFormatter(for dateFormat: DateFormat) -> DateFormatter {
        let dateFormat = dateFormat.rawValue
        if let cached = cached[dateFormat] { return cached }
        let formatter = createFormatter(for: dateFormat)
        cached[dateFormat] = formatter
        return formatter
    }
}

/// 날짜 포맷팅 및 달력 계산을 위한 클라이언트
struct DateClient {
    typealias Key = String
    
    var toString: @Sendable (Date, DateFormat) async -> String
    var monthKey: @Sendable (Date) async -> Key
    var dayKey: @Sendable (Date) async -> Key
    var startOfDay: @Sendable (Date) -> Date
}

// MARK: - DependencyKey
extension DateClient: DependencyKey {
    private static let formatterCache = DateFormatterCached()
    
    static var liveValue: DateClient = .init { date, dateFormat in
        await formatterCache.cachedFormatter(for: dateFormat).string(from: date)
    } monthKey: { date in
        await formatterCache.cachedFormatter(for: .yyyyMM).string(from: date)
    } dayKey: { date in
        await formatterCache.cachedFormatter(for: .yyyyMMdd).string(from: date)
    } startOfDay: { date in
        @Dependency(\.calendar) var calendar
        return calendar.startOfDay(for: date)
    }
}

// MARK: - DependencyValues
extension DependencyValues {
    var dateClient: DateClient {
        get { self[DateClient.self] }
        set { self[DateClient.self] = newValue }
    }
}
