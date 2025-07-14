//
//  FeeCombination.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/8/25.
//

import Foundation

struct FeeCombination: Identifiable, Hashable {
    let id: UUID = UUID()
    let fees: [UInt: Int]
    
    init(fees: [UInt : Int]) {
        self.fees = fees
    }
    
    init(fees: [UInt]) {
        self.fees = fees.reduce(into: [:]) { result, fee in
            result[fee, default: 0] += 1
        }
    }
}
