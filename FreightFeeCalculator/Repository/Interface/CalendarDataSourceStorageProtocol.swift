//
//  CalendarDataSourceStorageProtocol.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/23/25.
//

import Foundation

protocol CalendarDataSourceStorageProtocol {
    func createMonth(with month: Month) async throws
    func readMonth(with id: UUID) async throws -> Month
    func updateMonth(with id: UUID) async throws
    func deleteMonth(with id: UUID) async throws
}
