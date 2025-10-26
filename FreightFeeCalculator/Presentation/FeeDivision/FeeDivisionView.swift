//
//  FeeDivisionView.swift
//  FreightFeeCalculator
//
//  Created by SwainYun on 10/26/25.
//

import SwiftUI
import ComposableArchitecture

private typealias KeyboardFocus = FeeDivisionFeature.KeyboardFocus

struct FeeDivisionView: View {
    @Bindable var store: StoreOf<FeeDivisionFeature>
    @FocusState private var keyboardFocus: KeyboardFocus?
    
    init(store: StoreOf<FeeDivisionFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            ForEach(store.formattedResult) { fee in
                Text("\(fee.key.formatted(.currency(code: "KRW"))) x \(fee.value)")
                    .font(.title.bold())
                    .monospaced()
            }
            
            if let errorMessage = store.errorMessage {
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
                        
                        TextField("Total", text: $store.total)
                            .keyboardType(.numberPad)
                            .focused($keyboardFocus, equals: .total)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                            )
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Count")
                            .font(.headline)
                        
                        TextField("Count", text: $store.count)
                            .keyboardType(.numberPad)
                            .focused($keyboardFocus, equals: .count)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                            )
                    }
                    
                    Picker("\(store.mode.value)", selection: $store.mode) {
                        ForEach(DividingMode.allCases) { mode in
                            Text("Divide by \(mode.value)")
                        }
                    }
                }
                
                Button {
                    store.send(.view(.calculateButtonTapped))
                } label: {
                    Text("Calculate")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(store.isCalculateButtonDisabled)
                .padding(.top)
            }
            .safeAreaPadding(.bottom)
        }
        .padding()
        .contentShape(.rect)
        .onTapGesture { store.send(.view(.dismissKeyboard)) }
        .bind($store.keyboardFocus, to: $keyboardFocus)
    }
}

#Preview {
    FeeDivisionView(store: .init(initialState: FeeDivisionFeature.State(), reducer: { FeeDivisionFeature() }))
}
