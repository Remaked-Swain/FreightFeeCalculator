//
//  Day.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/17/25.
//

import Foundation

struct Day: Identifiable {
    let id: String
    let day: Int
    let date: Date
    let isValid: Bool
    var workHours: WorkHours?
    var hasWorked: Bool { workHours != nil }
    
    init(
        _ id: String = UUID().uuidString,
        _ date: Date,
        _ day: Int,
        isValid: Bool,
        workHours: WorkHours? = nil
    ) {
        self.id = id
        self.day = day
        self.date = date
        self.isValid = isValid
        self.workHours = workHours
    }
}
