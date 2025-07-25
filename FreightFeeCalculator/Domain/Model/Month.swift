//
//  Month.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/17/25.
//

import Foundation

struct Month: Identifiable {
    let id: UUID
    let startDate: Date
    var days: [Day] { _days.values.sorted { $0.date < $1.date } }
    
    private var _days: [String: Day]
    
    init(
        _ id: UUID,
        _ days: [String: Day],
        _ startDate: Date
    ) {
        self.id = id
        self.startDate = startDate
        self._days = days
    }
    
    func day(for date: Date) async -> Day? {
        await _days[date.dayKey()]
    }
}
