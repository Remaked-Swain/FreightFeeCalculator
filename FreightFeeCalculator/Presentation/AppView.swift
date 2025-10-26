//
//  AppView.swift
//  FreightFeeCalculator
//
//  Created by SwainYun on 10/26/25.
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>
    
    var body: some View {
        TabView(selection: $store.selectedTab) {
            Tab(value: AppFeature.Tab.feeDivision) {
                NavigationStack {
                    FeeDivisionView(store: store.scope(state: \.feeDivision, action: \.feeDivision))
                }
            } label: {
                Label("운임비 계산", systemImage: "box.truck")
            }
            
            Tab(value: AppFeature.Tab.calendar) {
                NavigationStack {
                    CalendarView(store: store.scope(state: \.calendar, action: \.calendar))
                }
            } label: {
                Label("캘린더", systemImage: "calendar")
            }

        }
    }
}

#Preview {
    AppView(store: .init(initialState: AppFeature.State(), reducer: { AppFeature() }))
}
