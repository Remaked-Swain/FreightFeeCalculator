//
//  ContentView.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/14/25.
//

import SwiftUI

struct ContentView: View {
    private let spacing: CGFloat = 24
    
    var body: some View {
        Grid(horizontalSpacing: spacing, verticalSpacing: spacing) {
            NavigationLink {
                FeeDivisionView()
            } label: {
                Text("Fee Division")
                    .font(.headline)
            }
        }
        .navigationTitle("Freight Fee Calculator")
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
    .preferredColorScheme(.light)
}

#Preview {
    NavigationStack {
        ContentView()
    }
    .preferredColorScheme(.dark)
}
