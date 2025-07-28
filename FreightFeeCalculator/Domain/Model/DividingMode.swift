//
//  DividingMode.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/8/25.
//

import Foundation

/// 운임비 분배 기준
///
/// - `byThousand`: 1000원 단위로 운임비를 분배합니다.
/// - `byHundreds`: 100원 단위로 운임비를 분배합니다.
/// - `byTens`: 10원 단위로 운임비를 분배합니다.
enum DividingMode: Identifiable, CaseIterable {
    case byThousand
    case byHundreds
    case byTens
    
    var id: Self { self }
    
    var value: UInt {
        switch self {
        case .byThousand: 1000
        case .byHundreds: 100
        case .byTens: 10
        }
    }
}
