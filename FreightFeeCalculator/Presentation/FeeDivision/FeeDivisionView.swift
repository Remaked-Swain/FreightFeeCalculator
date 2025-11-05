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
            ZStack(alignment: .topLeading) {
                resultsList
                
                packageGroupsSection
            }
            
            initialValueSection
        }
        .padding()
        .contentShape(.rect)
        .onTapGesture { store.send(.view(.dismissKeyboard)) }
        .bind($store.keyboardFocus, to: $keyboardFocus)
        .toolbar { toolbarContent }
    }
}

// MARK: - Subviews
private extension FeeDivisionView {
    @ViewBuilder var resultsList: some View {
        ZStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(store.formattedCombinations) { combination in
                        resultCell(combination)
                    }
                }
            }
            .scrollIndicators(.never)
            .scrollDismissesKeyboard(.interactively)
            
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
        }
    }
    
    @ViewBuilder func resultCell(_ combination: FeeDivisionFeature.IdentifiableCombination) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(combination.formattedFees) { fee in
                Text("\(fee.key.formatted(.currency(code: "KRW"))) x \(fee.value)")
                    .font(.title3.bold())
                    .monospaced()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    @ViewBuilder var initialValueSection: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("운임비 합계")
                    .font(.headline)
                
                TextField("입력하세요", text: $store.total)
                    .keyboardType(.numberPad)
                    .focused($keyboardFocus, equals: .total)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
            }
            
            VStack(alignment: .trailing) {
                Picker("운임 종류", selection: $store.shippingType) {
                    ForEach(ShippingType.allCases) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                
                Picker("분배 단위", selection: $store.mode) {
                    ForEach(DividingMode.allCases) { mode in
                        Text("\(mode.value)원").tag(mode)
                    }
                }
            }
        }
    }
    
    @ViewBuilder var packageGroupsSection: some View {
        DisclosureGroup(isExpanded: $store.isPackageGroupExpanded) {
            LazyVStack(alignment: .leading) {
                ForEach($store.packageGroups) { $packageGroup in
                    packageGroupRow(for: $packageGroup)
                }
            }
        } label: {
            Text("\(store.packageGroups.count)")
                .font(.headline)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    @ViewBuilder func packageGroupRow(for packageGroup: Binding<PackageGroup>) -> some View {
        HStack(spacing: 12) {
            Picker("Type", selection: packageGroup.type) {
                ForEach(PackageType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            
            Stepper("\(packageGroup.wrappedValue.count)", value: packageGroup.count, in: 1...30)
            
            Button {
                store.send(.view(.removePackageGroup(id: packageGroup.wrappedValue.id)))
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title2)
            }
            .buttonStyle(.plain)
        }
    }
    
    @ToolbarContentBuilder var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                store.send(.view(.addPackageGroupButtonTapped))
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
            }
            .buttonStyle(.glassProminent)
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                store.send(.view(.calculateButtonTapped))
            } label: {
                Text("Calculate")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .disabled(store.isCalculateButtonDisabled)
        }
    }
}

#Preview {
    NavigationStack {
        FeeDivisionView(store: .init(initialState: FeeDivisionFeature.State(), reducer: { FeeDivisionFeature() }))
    }
}
