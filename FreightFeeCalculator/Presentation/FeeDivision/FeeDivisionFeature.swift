//
//  FeeDivisionFeature.swift
//  FreightFeeCalculator
//
//  Created by SwainYun on 10/25/25.
//

import Foundation
import ComposableArchitecture

// MARK: - Nested Types
extension FeeDivisionFeature {
    enum KeyboardFocus {
        case total
    }
    
    struct FormattedFee: Identifiable, Equatable {
        let id = UUID()
        let key: UInt
        let value: Int
    }
    
    struct IdentifiableCombination: Identifiable, Equatable {
        let id: UUID
        let formattedFees: [FormattedFee]
    }
}

@Reducer
struct FeeDivisionFeature {
    private enum CancelID {
        case calculate
    }
    
    @ObservableState
    struct State: Equatable {
        var errorMessage: String?
        var total: String = ""
        var mode: DividingMode = .byThousand
        var shippingType: ShippingType = .parcel
        var packageGroups: IdentifiedArrayOf<PackageGroup> = []
        var isPackageGroupExpanded: Bool = true
        var calculationResult: [FeeCombination] = []
        var keyboardFocus: KeyboardFocus?
        
        var totalCount: Int { packageGroups.reduce(0) { $0 + $1.count } }
        var isCalculateButtonDisabled: Bool { UInt(total) == nil || totalCount <= .zero || packageGroups.contains { $0.count <= .zero } }
        var formattedCombinations: [IdentifiableCombination] {
            calculationResult.map { combination in
                let sortedFees = combination.fees.sorted {
                    guard $0.value != $1.value else { return $0.key < $1.key }
                    return $0.value > $1.value
                }
                
                let formatted = sortedFees.map { FormattedFee(key: $0.key, value: $0.value) }
                return IdentifiableCombination(id: combination.id, formattedFees: formatted)
            }
        }
    }
    
    @CasePathable
    enum Action: BindableAction {
        enum ViewAction {
            case calculateButtonTapped
            case dismissKeyboard
            case addPackageGroupButtonTapped
            case removePackageGroup(id: PackageGroup.ID)
        }
        
        enum InnerAction {
            case calculationResponse(Result<[FeeCombination], Error>)
        }
        
        case view(ViewAction)
        case inner(InnerAction)
        case binding(BindingAction<State>)
    }
    
    @Dependency(\.feeCalculationClient) var feeCalculationClient
    @Dependency(\.uuid) var uuid
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                return handleViewAction(&state, viewAction)
                
            case let .inner(innerAction):
                return handleInnerAction(&state, innerAction)
                
            case .binding(\.total), .binding(\.packageGroups), .binding(\.mode), .binding(\.shippingType):
                return .cancel(id: CancelID.calculate)
                
            case .binding(\.isPackageGroupExpanded):
                return .none
                
            case .binding:
                return .none
            }
        }
    }
    
    private func handleViewAction(_ state: inout State, _ viewAction: Action.ViewAction) -> Effect<Action> {
        switch viewAction {
        case .calculateButtonTapped:
            state.calculationResult = []
            state.errorMessage = nil
            
            guard let total: UInt = UInt(state.total), state.totalCount > .zero else {
                state.errorMessage = "잘못된 값 입력"
                return .none
            }
            
            let mode: DividingMode = state.mode
            let shippingType = state.shippingType
            let packageGroups = state.packageGroups.elements
            let totalCount = state.totalCount
            return .run { send in
                await send(.inner(.calculationResponse(Result {
                    try await feeCalculationClient.calculateFee(total, totalCount, packageGroups, shippingType, mode)
                })))
            }
            .cancellable(id: CancelID.calculate)
            
        case .dismissKeyboard:
            state.keyboardFocus = nil
            return .none
            
        case .addPackageGroupButtonTapped:
            let newGroup = PackageGroup(id: uuid())
            state.packageGroups.append(newGroup)
            state.isPackageGroupExpanded = true
            return .none
            
        case .removePackageGroup(let id):
            state.packageGroups.remove(id: id)
            return .none
        }
    }
    
    private func handleInnerAction(_ state: inout State, _ innerAction: Action.InnerAction) -> Effect<Action> {
        switch innerAction {
        case .calculationResponse(.success(let combinations)):
            state.calculationResult = combinations
            state.errorMessage = nil
            state.isPackageGroupExpanded = false
            return .none
            
        case .calculationResponse(.failure(let error)):
            state.errorMessage = error.localizedDescription
            return .none
        }
    }
}
