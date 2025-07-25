//
//  CalendarView.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/19/25.
//

import SwiftUI
import Swinject

struct CalendarView: View {
    @State private var viewModel: CalendarViewModel
    @FocusState private var isFocused: Bool
    
    init(_ resolver: Resolver) {
        self.viewModel = resolver.resolve(CalendarViewModel.self)!
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CalendarHeader(viewModel: viewModel)
            
            TabView(selection: $viewModel.calendarIndex) {
                ForEach(viewModel.months.indices, id: \.self) { index in
                    CalendarGrid(viewModel: viewModel, month: viewModel.months[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            Spacer()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Rate")
                        .font(.headline)
                    
                    TextField("Rate", text: $viewModel.rate)
                        .keyboardType(.numberPad)
                        .focused($isFocused)
                        .submitLabel(.return)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                        )
                }
                
                Picker("\(viewModel.selectedWorkHours.value)시간", selection: $viewModel.selectedWorkHours) {
                    ForEach(WorkHours.allCases) { workHour in
                        Text("\(workHour.value)시간")
                            .tag(workHour)
                    }
                }
            }
            .padding()
            
            Button {
                viewModel.calculatePay()
                isFocused = false
            } label: {
                Text("Calculate")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .frame(alignment: .bottom)
            .safeAreaPadding(.bottom)
            .padding()
        }
        .onAppear {
            viewModel.loadCalendarDataSource(for: .now)
        }
    }
}

// MARK: - Subviews
extension CalendarView {
    struct CalendarHeader: View {
        let viewModel: CalendarViewModel
        
        var body: some View {
            VStack(spacing: 12) {
                HStack(alignment: .bottom, spacing: 12) {
                    AsyncDateView(date: viewModel.selectedMonth?.startDate, format: .yyyyMMKorean, prompt: "로딩 중...")
                        .font(.title)
                    
                    Spacer()
                    
                    Text("\(viewModel.errorMessage ?? viewModel.totalPay.formatted(.currency(code: "KRW")))")
                        .font(.headline)
                        .monospacedDigit()
                }
                .padding([.top, .horizontal])
                
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
        let viewModel: CalendarViewModel
        let month: Month
        
        private let columns: [GridItem] = .init(repeating: .init(), count: DayOfWeek.count)
        
        var body: some View {
            VStack {
                LazyVGrid(columns: columns, spacing: .zero) {
                    ForEach(month.days) { day in
                        CalendarCell(viewModel: viewModel, day: day)
                    }
                }
            }
        }
    }
    
    struct CalendarCell: View {
        let viewModel: CalendarViewModel
        let day: Day
        
        init(viewModel: CalendarViewModel, day: Day) {
            self.viewModel = viewModel
            self.day = day
        }
        
        var body: some View {
            Button {
                viewModel.onTapDayCell(day)
            } label: {
                VStack(spacing: 4) {
                    Text("\(day.day)")
                    
                    Circle()
                        .fill(backgroundStyle(day.workHours))
                        .frame(width: 10, height: 10)
                }
                .foregroundStyle(foregroundStyle(day.isValid))
            }
            .padding(.vertical, 10)
            .disabled(day.isValid == false)
        }
        
        private func foregroundStyle(_ isValid: Bool) -> Color {
            isValid ? .accentColor : .gray
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

#Preview {
    CalendarView(PreviewHelper.shared.resolver)
}
