//
//  ContentView.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/14/25.
//

import SwiftUI
import Swinject

struct ContentView: View {
    private let resolver: Resolver
    private let spacing: CGFloat = 24
    
    init(resolver: Resolver) {
        self.resolver = resolver
    }
    
    var body: some View {
        Grid(horizontalSpacing: spacing, verticalSpacing: spacing) {
            NavigationLink {
                FeeDivisionView(resolver)
            } label: {
                Text("Fee Division")
                    .font(.headline)
            }
            
            NavigationLink {
                CalendarView(resolver)
            } label: {
                Text("Calendar")
                    .font(.headline)
            }
        }
        .navigationTitle("Freight Fee Calculator")
    }
}
