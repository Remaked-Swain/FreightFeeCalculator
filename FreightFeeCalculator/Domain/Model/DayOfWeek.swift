//
//  DayOfWeek.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/17/25.
//

import Foundation

/// 요일
///
/// - Note: 요일은 일요일부터 시작합니다. `CaseIterable`
enum DayOfWeek: String, CaseIterable {
    case sun = "일"
    case mon = "월"
    case tue = "화"
    case wed = "수"
    case thu = "목"
    case fri = "금"
    case sat = "토"
    
    static var count: Int { DayOfWeek.allCases.count }
    
    var inShortKorean: String {
        self.rawValue
    }
}
