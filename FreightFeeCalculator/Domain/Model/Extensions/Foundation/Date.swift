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
