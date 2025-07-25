//
//  WorkHours.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/17/25.
//

import Foundation

/// 근무 시간
enum WorkHours: Int, CaseIterable {
    case three = 3, four = 4
    
    var value: Int { self.rawValue }
}

// MARK: - Identifiable Conformation
extension WorkHours: Identifiable {
    var id: Int { self.rawValue }
}
