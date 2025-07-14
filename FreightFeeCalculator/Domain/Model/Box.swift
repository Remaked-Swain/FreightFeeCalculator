//
//  Box.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/8/25.
//

import Foundation

struct Box: Identifiable, Hashable {
    let id: UUID = UUID()
    /// 가로 길이
    var width: Double?
    /// 세로 길이
    var height: Double?
    /// 높이
    var depth: Double?
    
    /// 박스의 모든 치수가 설정되었는지 판단하는 flag
    var isAllDimensionSet: Bool {
        width != nil && height != nil && depth != nil
    }
    
    /// 부피
    var volume: Double? {
        guard let width, let height, let depth else { return nil }
        return width * height * depth
    }
    
    init(width: Double? = nil, height: Double? = nil, depth: Double? = nil) {
        self.width = width
        self.height = height
        self.depth = depth
    }
}
