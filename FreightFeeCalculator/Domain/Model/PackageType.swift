//
//  PackageType.swift
//  FreightFeeCalculator
//
//  Created by SwainYun on 11/4/25.
//

import Foundation

/// 포장 종류
enum PackageType: String, CaseIterable, Identifiable {
    /// 박스
    case box = "박스"
    /// 통
    case bucket = "통"
    /// 비닐
    case plasticWrap = "비닐"
    /// 나체
    case raw = "나체"
    
    var id: Self { self }
}
