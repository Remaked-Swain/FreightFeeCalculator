//
//  CalendarFeature.swift
//  FreightFeeCalculator
//
//  Created by SwainYun on 10/26/25.
//

import Foundation
import ComposableArchitecture

extension CalendarFeature {
    enum KeyboardFocus {
        case rate
    }
    
    enum CalendarPagingDirection {
        case previous, next
    }
}

@Reducer
struct CalendarFeature {
    private enum CancelID {
        case calendarLoad
        case dayUpdate
        case salaryCalculate
        case monthSave
    }
    
    @ObservableState
    struct State: Equatable {
        var months: [Month] = []
        var totalPay: Double = .zero
        var isLoading: Bool = false
        var errorMessage: String?
        var selectedMonthTitle: String = "로딩 중..."
        var calendarIndex: Int = 1
        var rate: String = "11000"
        var selectedWorkHours: WorkHours = .three
        var keyboardFocus: KeyboardFocus?
        
        var selectedMonth: Month? {
            guard months.count == 3 else { return nil }
            return months[1]
        }
    }
    
    @CasePathable
    enum Action: BindableAction {
        enum ViewAction {
            case onAppear
            case dayTapped(Day)
            case calculateButtonTapped
            case dismissKeyboard
        }
        
        enum InnerAction {
            case calendarLoadResponse(Result<[Month], Error>)
            case calendarPageResponse(Result<[Month], Error>)
            case dayUpdateResponse(Result<Month, Error>)
            case salaryCalculateResponse(Result<Double, Error>)
            case _setHeaderTitle(String)
            case _monthSaveResponse(Result<Void, Error>)
        }
        
        case view(ViewAction)
        case inner(InnerAction)
        case binding(BindingAction<State>)
    }
    
    @Dependency(\.calendarDataClient) var calendarDataClient
    @Dependency(\.salaryCalculatorClient) var salaryCalculatorClient
    @Dependency(\.date) var date
    @Dependency(\.dateClient) var dateClient
    @Dependency(\.calendar) var calendar
    @Dependency(\.uuid) var uuid
    
    private var totalDaysCount: Int { 7 * 6 }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                guard state.months.isEmpty else { return .none }
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { [date = date.now] send in
                    await send(.inner(.calendarLoadResponse(Result {
                        try await generateInitialMonths(for: date)
                    })))
                }
                
            case .view(.dayTapped(let day)):
                guard state.selectedMonth != nil else {
                    state.errorMessage = "아직 달력이 구성되지 않음"
                    return .none
                }
                
                let newWorkHours: WorkHours? = day.hasWorked
                ? (day.workHours == state.selectedWorkHours ? nil : state.selectedWorkHours)
                : state.selectedWorkHours
                
                return .run { send in
                    await send(.inner(.dayUpdateResponse(Result {
                        try await updateWorkStatus(on: day, hours: newWorkHours)
                    })))
                }
                .cancellable(id: CancelID.dayUpdate, cancelInFlight: true)
                
            case .view(.calculateButtonTapped):
                guard let month = state.selectedMonth else {
                    state.errorMessage = "아직 달력이 구성되지 않음"
                    return .none
                }
                
                guard let rate = Double(state.rate), rate > .zero else {
                    state.errorMessage = "유효한 급여를 입력하세요."
                    return .none
                }
                
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { send in
                    await send(.inner(.salaryCalculateResponse(Result {
                        salaryCalculatorClient.calculate(month, rate)
                    })))
                }
                .cancellable(id: CancelID.salaryCalculate)
                
            case .view(.dismissKeyboard):
                state.keyboardFocus = nil
                return .none
                
            case .inner(.calendarLoadResponse(.success(let months))):
                return handleCalendarLoadSuccess(state: &state, months: months)
                
            case .inner(.calendarLoadResponse(.failure(let error))):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                state.months = []
                return .none
                
            case .inner(.calendarPageResponse(.success(let months))):
                return handleCalendarLoadSuccess(state: &state, months: months)
                
            case .inner(.calendarPageResponse(.failure(let error))):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                
            case .inner(.dayUpdateResponse(.success(let month))):
                state.months[state.calendarIndex] = month
                return .none
                
            case .inner(.dayUpdateResponse(.failure(let error))):
                state.errorMessage = error.localizedDescription
                return .none
                
            case .inner(.salaryCalculateResponse(.success(let pay))):
                state.isLoading = false
                state.totalPay = pay
                
                guard var selectedMonth = state.selectedMonth,
                      let rateDouble = Double(state.rate)
                else {
                    state.errorMessage = "월 정보 저장 실패"
                    return .none
                }
                
                selectedMonth.savedPay = pay
                selectedMonth.savedRate = rateDouble
                state.months[state.calendarIndex] = selectedMonth
                
                return .run { [selectedMonth] send in
                    await send(.inner(._monthSaveResponse(Result {
                        try await calendarDataClient.saveMonth(selectedMonth)
                    })))
                }
                .cancellable(id: CancelID.monthSave)
                
            case .inner(.salaryCalculateResponse(.failure(let error))):
                state.isLoading = false
                state.errorMessage = "계산 실패: \(error.localizedDescription)"
                state.totalPay = .zero
                return .none
                
            case .inner(._setHeaderTitle(let title)):
                state.selectedMonthTitle = title
                return .none
                
            case .inner(._monthSaveResponse(.success)):
                return .none
                
            case .inner(._monthSaveResponse(.failure)):
                state.errorMessage = "급여 정보 저장 실패"
                return .none
                
            case .binding(\.calendarIndex):
                guard state.calendarIndex != 1 else { return .none }
                let direction: CalendarPagingDirection = state.calendarIndex == 0 ? .previous : .next
                
                return .run { [months = state.months] send in
                    await send(.inner(.calendarPageResponse(Result {
                        try await updateMonthsForPaging(with: months, direction: direction)
                    })))
                }
                .cancellable(id: CancelID.calendarLoad)
                
            case .binding(\.rate):
                state.errorMessage = nil
                state.totalPay = .zero
                return .cancel(id: CancelID.salaryCalculate)
                
            case .binding:
                return .none
            }
        }
    }
}

// MARK: - Helper
extension CalendarFeature {
    private func handleCalendarLoadSuccess(state: inout State, months: [Month]) -> Effect<Action> {
        state.isLoading = false
        state.months = months
        state.calendarIndex = 1
        
        guard let selectedMonth = state.selectedMonth else {
            state.errorMessage = "달력 로드 실패"
            return .none
        }
        
        state.totalPay = selectedMonth.savedPay ?? .zero
        
        if let savedRate = selectedMonth.savedRate { state.rate = String(savedRate) }
        
        return .run { send in
            let title = await dateClient.toString(selectedMonth.startDate, .yyyyMMKorean)
            await send(.inner(._setHeaderTitle(title)))
        }
    }
    
    private func generateInitialMonths(for date: Date) async throws -> [Month] {
        guard let previousMonthDate = calendar.date(byAdding: .month, value: -1, to: date),
              let nextMonthDate = calendar.date(byAdding: .month, value: 1, to: date)
        else { throw CalendarError.invalidDate }
        
        async let previous = try prepareMonth(previousMonthDate)
        async let current = try prepareMonth(date)
        async let next = try prepareMonth(nextMonthDate)
        return try await [previous, current, next]
    }
    
    private func updateMonthsForPaging(with currentMonths: [Month], direction: CalendarPagingDirection) async throws -> [Month] {
        guard currentMonths.count == 3 else { throw CalendarError.dataNotFound("아직 달력이 구성되지 않음") }
        var newMonths: [Month]
        switch direction {
        case .previous:
            guard let newDate = calendar.date(byAdding: .month, value: -1, to: currentMonths[0].startDate) else { throw CalendarError.invalidDate }
            let newMonth = try await prepareMonth(newDate)
            newMonths = [newMonth, currentMonths[0], currentMonths[1]]
        case .next:
            guard let newDate = calendar.date(byAdding: .month, value: 1, to: currentMonths[2].startDate) else { throw CalendarError.invalidDate }
            let newMonth = try await prepareMonth(newDate)
            newMonths = [currentMonths[1], currentMonths[2], newMonth]
        }
        return newMonths
    }
    
    private func updateWorkStatus(on day: Day, hours: WorkHours?) async throws -> Month {
        let targetDate = day.date
        var currentDay = try await calendarDataClient.readDay(targetDate)
        
        guard currentDay.isValid else { throw ManageWorkStatusError.invalidDay }
        
        if currentDay.workHours != nil {
            currentDay.workHours = (currentDay.workHours == hours) ? nil : hours
        } else {
            currentDay.workHours = hours
        }
        
        try await calendarDataClient.saveDay(currentDay)
        return try await calendarDataClient.readMonth(targetDate)
    }
    
    private func prepareMonth(_ date: Date) async throws -> Month {
        if let cachedMonth = try? await calendarDataClient.readMonth(date) { return cachedMonth }
        let newMonth = try await generateMonth(date)
        try await calendarDataClient.saveMonth(newMonth)
        return newMonth
    }
    
    private func generateMonth(_ date: Date) async throws -> Month {
        guard let startDateOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else { throw CalendarError.invalidDate }
        let weekdayOfFirstDay = calendar.component(.weekday, from: startDateOfMonth)
        let numDaysBefore = (weekdayOfFirstDay - calendar.firstWeekday + 7) % 7
        
        guard let gridStartDate = calendar.date(byAdding: .day, value: -numDaysBefore, to: startDateOfMonth) else { throw CalendarError.invalidDate }
        
        var daysDict = [String: Day]()
        try await withThrowingTaskGroup { group in
            (0..<totalDaysCount).forEach { i in
                group.addTask {
                    guard let currentDate = calendar.date(byAdding: .day, value: i, to: gridStartDate) else { throw CalendarError.invalidDate }
                    let numberOfDay = calendar.component(.day, from: currentDate)
                    let isValid = calendar.isDate(currentDate, equalTo: startDateOfMonth, toGranularity: .month)
                    let day = Day(uuid().uuidString, currentDate, numberOfDay, isValid: isValid)
                    let key = await dateClient.dayKey(day.date)
                    return (key, day)
                }
            }
            
            for try await (key, day) in group {
                daysDict[key] = day
            }
        }
        
        return Month(uuid(), daysDict, startDateOfMonth)
    }
}
