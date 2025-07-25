//
//  CalendarWorkStatusRepositoryProtocol.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/17/25.
//

import Foundation

protocol CalendarDataSourceRepositoryProtocol {
    /// 특정 월의 Month 객체를 조회합니다.
    /// - Parameters:
    ///   - date: 조회할 월에 포함된 임의의 날짜
    /// - Returns: 조회한 Month 객체
    /// - Throws: 데이터가 없거나 조회 중 오류 발생 시 `RepositoryError`를 던집니다.
    func readMonth(_ date: Date) async throws -> Month
    
    /// Month 객체를 저장하거나 갱신합니다.
    /// - Parameters:
    ///   - month: 저장 또는 갱신할 Month 객체
    /// - Throws: 저장 중 오류 발생 시 `RepositoryError`를 던집니다.
    func saveMonth(_ month: Month) async throws
    
    /// 특정 월의 Month 데이터를 삭제합니다.
    /// - Parameters:
    ///   - date: 삭제할 월에 포함된 임의의 날짜
    /// - Throws: 삭제 중 오류 발생 시 `RepositoryError`를 던집니다.
    func deleteMonth(_ date: Date) async throws
    
    /// 특정 날짜의 Day 객체를 조회합니다.
    /// - Parameters:
    ///   - date: 조회할 날짜
    /// - Returns: 조회한 Day 객체
    /// - Throws: 데이터가 없거나 조회 중 오류 발생 시 `RepositoryError`를 던집니다.
    func readDay(_ date: Date) async throws -> Day
    
    /// Day 객체를 저장하거나 갱신합니다.
    /// - Parameters:
    ///   - day: 저장 또는 갱신할 Day 객체
    /// - Throws: 저장 중 오류 발생 시 `RepositoryError`를 던집니다.
    func saveDay(_ day: Day) async throws
}

enum RepositoryError: Error, LocalizedError {
    case dataNotFound(String)
    case saveFailed(String)
    case deleteFailed(String)
    case unknown(String)
    
    var errorDescription: String {
        switch self {
        case .dataNotFound(let message):
            return "데이터를 찾을 수 없습니다: \(message)"
        case .saveFailed(let message):
            return "데이터 저장에 실패했습니다: \(message)"
        case .deleteFailed(let message):
            return "데이터 삭제에 실패했습니다: \(message)"
        case .unknown(let message):
            return "알 수 없는 오류가 발생했습니다: \(message)"
        }
    }
}
