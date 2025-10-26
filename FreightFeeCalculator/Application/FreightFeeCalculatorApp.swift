//
//  FreightFeeCalculatorApp.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/8/25.
//

import SwiftUI
import ComposableArchitecture

@main
struct FreightFeeCalculatorApp: App {
    let store: StoreOf<AppFeature> = .init(initialState: AppFeature.State()) { AppFeature() }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: store)
        }
    }
}
