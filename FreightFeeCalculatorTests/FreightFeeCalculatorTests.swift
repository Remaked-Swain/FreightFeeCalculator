//
//  FreightFeeCalculatorTests.swift
//  FreightFeeCalculatorTests
//
//  Created by Swain Yun on 7/9/25.
//

import Testing
@testable import FreightFeeCalculator

struct FreightFeeCalculatorTests {
    @Test func testExactDivision() async throws {
        let calculator: FeeCalculator = FeeCalculator()
        let totalPrice: UInt = 10000
        let count: Int = 2
        let mode: DividingMode = .byHundreds
        let expectedFees: [UInt: Int] = [5000: 2]
        let combination: FeeCombination = try await calculator.calculate(totalPrice: totalPrice, count: count, mode: mode)
        #expect(combination.fees == expectedFees, "정확히 나누지 못함")
    }
    
    @Test func testRemainingDistributionByHundreds() async throws {
        let calculator: FeeCalculator = FeeCalculator()
        let totalPrice: UInt = 91500
        let count: Int = 4
        let mode: DividingMode = .byHundreds
        let expectedFees: [UInt: Int] = [22900: 3, 22800: 1]
        let combination: FeeCombination = try await calculator.calculate(totalPrice: totalPrice, count: count, mode: mode)
        #expect(combination.fees == expectedFees, "운임비 분배 계산(100원 단위)에 실패함")
    }
    
    @Test func testRemainingDistributionByTens() async throws {
        let calculator: FeeCalculator = FeeCalculator()
        let totalPrice: UInt = 12340
        let count: Int = 3
        let mode: DividingMode = .byTens
        let expectedFees: [UInt: Int] = [4110: 2, 4120: 1]
        let combination: FeeCombination = try await calculator.calculate(totalPrice: totalPrice, count: count, mode: mode)
        #expect(combination.fees == expectedFees, "운임비 분배 계산(10원 단위)에 실패함")
    }
    
    @Test func testZeroBoxCountThrowsError() async throws {
        let calculator: FeeCalculator = FeeCalculator()
        let totalPrice: UInt = 10000
        let count: Int = 0
        let mode: DividingMode = .byHundreds
        await #expect(throws: FeeCalculatorError.invalidInput) {
            _ = try await calculator.calculate(totalPrice: totalPrice, count: count, mode: mode)
        }
    }
    
    @Test func testLargeNumbers() async throws {
        let calculator: FeeCalculator = FeeCalculator()
        let totalPrice: UInt = 2_000_000_000
        let count = 100_000
        let mode: DividingMode = .byHundreds
        let expectedFees: [UInt: Int] = [20000: 100000]
        let combination: FeeCombination = try await calculator.calculate(totalPrice: totalPrice, count: count, mode: mode)
        #expect(combination.fees == expectedFees, "아주 큰 숫자에 대한 계산 실패")
    }
}
