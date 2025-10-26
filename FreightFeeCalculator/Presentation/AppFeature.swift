//
//  AppFeature.swift
//  FreightFeeCalculator
//
//  Created by SwainYun on 10/25/25.
//

import Foundation
import ComposableArchitecture

extension AppFeature {
    enum Tab { case feeDivision, calendar }
}

@Reducer
struct AppFeature {
    @ObservableState
    struct State {
        var feeDivision = FeeDivisionFeature.State()
        var calendar = CalendarFeature.State()
        var selectedTab: Tab = .feeDivision
    }
    
    @CasePathable
    enum Action: BindableAction {
        case feeDivision(FeeDivisionFeature.Action)
        case calendar(CalendarFeature.Action)
        case binding(BindingAction<State>)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Scope(state: \.feeDivision, action: \.feeDivision) { FeeDivisionFeature() }
        Scope(state: \.calendar, action: \.calendar) { CalendarFeature() }
    }
}
