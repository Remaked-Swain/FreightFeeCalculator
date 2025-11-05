//
//  ShippingType.swift
//  FreightFeeCalculator
//
//  Created by SwainYun on 11/4/25.
//

import Foundation

/// 운임 종류
enum ShippingType: Identifiable, CaseIterable {
    /// 택배
    case parcel
    /// 화물
    case freight
    
    var id: Self { self }
    
    var displayName: String {
        switch self {
        case .parcel: "택배"
        case .freight: "화물"
        }
    }
}

/// 운임 정책
struct ShippingPolicy {
    static func baseFee(for type: ShippingType) -> UInt {
        switch type {
        case .parcel: 6000
        case .freight: 4000
        }
    }
}
