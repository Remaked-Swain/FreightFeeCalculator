//
//  PackageGroup.swift
//  FreightFeeCalculator
//
//  Created by SwainYun on 11/4/25.
//

import Foundation

struct PackageGroup: Identifiable, Equatable, Hashable {
    let id: UUID
    var type: PackageType = .box
    var count: Int = 1
}
