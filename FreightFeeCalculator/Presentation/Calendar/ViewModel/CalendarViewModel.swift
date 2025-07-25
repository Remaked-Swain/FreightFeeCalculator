//
//  CalendarViewModel.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/18/25.
//

import Foundation
import Combine

@MainActor
@Observable
final class CalendarViewModel {
    private(set) var months: [Month] = []
    private(set) var totalPay: Double = .zero
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?
    var calendarIndex: Int = 1 { didSet { onIndexChange(calendarIndex) } }
    var rate: String = "11000"
    var selectedWorkHours: WorkHours = .three
    var selectedMonth: Month? {
        guard months.isEmpty == false, months.count == 3 else { return nil }
        return months[1]
    }
    
    private var loadCalendarTask: Task<Void, Never>?
    private var calculatePayTask: Task<Void, Never>?
    private var onTapDayCellTask: Task<Void, Never>?
    
    private let calendarUseCase: CalendarUseCaseProtocol
    private let calculateSalaryUseCase: CalculateSalaryUseCaseProtocol
    private let manageWorkStatusUseCase: ManageWorkStatusUseCaseProtocol
    
    init(
        calendarUseCase: CalendarUseCaseProtocol,
        calculateSalaryUseCase: CalculateSalaryUseCaseProtocol,
        manageWorkStatusUseCase: ManageWorkStatusUseCaseProtocol
    ) {
        self.calendarUseCase = calendarUseCase
        self.calculateSalaryUseCase = calculateSalaryUseCase
        self.manageWorkStatusUseCase = manageWorkStatusUseCase
    }
}

// MARK: - Helper Methods
private extension CalendarViewModel {
    func onIndexChange(_ newValue: Int) {
        guard newValue != 1 else { return }
        
        var direction: CalendarPagingDirection
        switch newValue {
        case 0: direction = .previous
        case 2: direction = .next
        default: return
        }
        
        loadCalendarTask?.cancel()
        
        loadCalendarTask = Task {
            isLoading = true
            errorMessage = nil
            
            do {
                months = try await calendarUseCase.updateMonthsForPaging(with: months, direction: direction)
                calendarIndex = 1
            } catch let error as CalendarError {
                errorMessage = error.localizedDescription
            } catch {
                errorMessage = "알 수 없는 에러가 발생했습니다: \(error.localizedDescription)"
            }
            
            isLoading = false
        }
    }
}

// MARK: - Interfaces
extension CalendarViewModel {
    func loadCalendarDataSource(for date: Date) {
        loadCalendarTask?.cancel()
        
        loadCalendarTask = Task {
            isLoading = true
            errorMessage = nil
            
            do {
                months = try await calendarUseCase.generateInitialMonths(for: date)
                calendarIndex = 1
            } catch let error as CalendarError {
                errorMessage = error.localizedDescription
                months = []
            } catch {
                errorMessage = "알 수 없는 에러가 발생했습니다: \(error.localizedDescription)"
                months = []
            }
            
            isLoading = false
        }
    }
    
    func onTapDayCell(_ day: Day) {
        guard months.isEmpty == false else { return errorMessage = "아직 달력이 구성되지 않았습니다." }
        
        onTapDayCellTask?.cancel()
        
        onTapDayCellTask = Task {
            isLoading = true
            errorMessage = nil
            
            let newWorkHours: WorkHours? = day.hasWorked ? day.workHours == selectedWorkHours ? nil : selectedWorkHours : selectedWorkHours
            
            do {
                let month = try await manageWorkStatusUseCase.execute(on: day, hours: newWorkHours)
                months[calendarIndex] = month
            } catch let error as CalendarError {
                errorMessage = error.localizedDescription
            } catch {
                errorMessage = "알 수 없는 에러가 발생했습니다: \(error.localizedDescription)"
            }
            
            isLoading = false
        }
    }
    
    func calculatePay() {
        guard months.isEmpty == false else { return errorMessage = "아직 달력이 구성되지 않았습니다." }
        
        calculatePayTask?.cancel()
        
        calculatePayTask = Task {
            guard let rate = Double(rate), rate > .zero else { return errorMessage = "유효한 급여를 입력해야 합니다." }
            
            isLoading = true
            errorMessage = nil
            
            do {
                totalPay = try await calculateSalaryUseCase.execute(for: months[1], rate: rate)
            } catch {
                errorMessage = "계산 실패: \(error.localizedDescription)"
                totalPay = .zero
            }
            
            isLoading = false
        }
    }
}
