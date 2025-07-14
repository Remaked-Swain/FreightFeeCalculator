//
//  ContentView.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/8/25.
//

import SwiftUI

struct ContentView: View {
    @State private var feeCombinationViewModel = FeeCombinationViewModel()
    @FocusState private var keyboardFocusType: KeyboardFocusType?
    
    var body: some View {
        @Bindable var feeCombinationViewModel = feeCombinationViewModel
        
        VStack {
            Spacer()
            
            ForEach(feeCombinationViewModel.calculateResult, id: \.self) {
                Text($0)
                    .font(.title.bold())
                    .monospaced()
            }
            
            if let errorMessage = feeCombinationViewModel.errorMessage {
                Text(errorMessage)
                    .font(.headline)
                    .foregroundStyle(.red)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .shadow(radius: 10)
                    )
            }
            
            Spacer()
            
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Total")
                            .font(.headline)
                        
                        TextField("Total", text: $feeCombinationViewModel.total)
                            .keyboardType(.numberPad)
                            .focused($keyboardFocusType, equals: .total)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                            )
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Count")
                            .font(.headline)
                        
                        TextField("Count", text: $feeCombinationViewModel.count)
                            .keyboardType(.numberPad)
                            .focused($keyboardFocusType, equals: .count)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                            )
                    }
                    
                    Picker("\(feeCombinationViewModel.mode.value)", selection: $feeCombinationViewModel.mode) {
                        ForEach(DividingMode.allCases) { mode in
                            Text("Divide by \(mode.value)")
                        }
                    }
                }
                
                Button {
                    feeCombinationViewModel.calculate()
                } label: {
                    Text("Calculate")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
            }
            .safeAreaPadding(.bottom)
        }
        .padding()
        .contentShape(.rect)
        .onTapGesture { keyboardFocusType = nil }
        .navigationTitle("운임비 계산기")
    }
}

// MARK: - Nested Types
extension ContentView {
    enum KeyboardFocusType: Hashable {
        case total, count
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
