//
//  CalendarView.swift
//  FreightFeeCalculator
//
//  Created by SwainYun on 10/26/25.
//

import SwiftUI
import ComposableArchitecture

private typealias KeyboardFocus = CalendarFeature.KeyboardFocus

struct CalendarView: View {
    @Bindable var store: StoreOf<CalendarFeature>
    @FocusState private var keyboardFocus: KeyboardFocus?
    
    var body: some View {
        VStack(spacing: .zero) {
            CalendarHeader(store: store)
            
            TabView(selection: $store.calendarIndex) {
                ForEach(store.months.indices, id: \.self) { index in
                    CalendarGrid(store: store, month: store.months[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .overlay {
                if store.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.black.opacity(0.1))
                }
            }
            
            Spacer()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Rate")
                        .font(.headline)
                    
                    TextField("Rate", text: $store.rate)
                        .keyboardType(.numberPad)
                        .focused($keyboardFocus, equals: .rate)
                        .submitLabel(.return)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                        )
                }
                
                Picker("\(store.selectedWorkHours.value)시간", selection: $store.selectedWorkHours) {
                    ForEach(WorkHours.allCases) { workHour in
                        Text("\(workHour.value)시간")
                            .tag(workHour)
                    }
                }
            }
            .padding()
            
            Button {
                store.send(.view(.calculateButtonTapped))
                store.send(.view(.dismissKeyboard))
            } label: {
                Text("Calculate")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .frame(alignment: .bottom)
            .safeAreaPadding(.bottom)
            .padding()
        }
        .onAppear { store.send(.view(.onAppear)) }
        .bind($store.keyboardFocus, to: $keyboardFocus)
    }
}

// MARK: - Subviews
extension CalendarView {
    struct CalendarHeader: View {
        let store: StoreOf<CalendarFeature>
        
        var body: some View {
            VStack(spacing: 12) {
                HStack(alignment: .bottom, spacing: 12) {
                    Text(store.selectedMonthTitle)
                        .font(.title)
                        .id(store.selectedMonthTitle)
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                    
                    Spacer()
                    
                    Text(store.errorMessage ?? store.totalPay.formatted(.currency(code: "KRW")))
                        .font(.headline)
                        .monospacedDigit()
                        .foregroundStyle(store.errorMessage != nil ? .red : .primary)
                }
                .padding([.top, .horizontal])
                .animation(.default, value: store.selectedMonthTitle)
                .animation(.default, value: store.errorMessage)
                .animation(.default, value: store.totalPay)
                
                Divider()
                
                HStack {
                    ForEach(DayOfWeek.allCases, id: \.self) { dayOfWeek in
                        Text(dayOfWeek.inShortKorean)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
    
    struct CalendarGrid: View {
        let store: StoreOf<CalendarFeature>
        let month: Month
        
        private let columns: [GridItem] = .init(repeating: .init(), count: DayOfWeek.count)
        
        var body: some View {
            VStack {
                LazyVGrid(columns: columns, spacing: .zero) {
                    ForEach(month.days) { day in
                        CalendarCell(store: store, day: day)
                    }
                }
            }
        }
    }
    
    struct CalendarCell: View {
        let store: StoreOf<CalendarFeature>
        let day: Day
        
        var body: some View {
            Button {
                store.send(.view(.dayTapped(day)))
            } label: {
                VStack(spacing: 4) {
                    Text("\(day.day)")
                        .frame(maxWidth: .infinity)
                    
                    Circle()
                        .fill(backgroundStyle(day.workHours))
                        .frame(width: 10, height: 10)
                }
                .padding(.bottom, 8)
                .foregroundStyle(foregroundStyle(day.isValid))
            }
            .padding(.vertical, 10)
            .disabled(day.isValid == false)
            .background {
                if Calendar.current.isDateInToday(day.date) && day.isValid {
                    Circle().fill(.secondary.opacity(0.3))
                        .frame(width: 30, height: 30)
                }
            }
        }
        
        private func foregroundStyle(_ isValid: Bool) -> Color {
            isValid ? .primary : .secondary
        }
        
        private func backgroundStyle(_ workHours: WorkHours?) -> Color {
            guard let workHours else { return .clear }
            switch workHours {
            case .three: return .green
            case .four: return .pink
            }
        }
    }
}
