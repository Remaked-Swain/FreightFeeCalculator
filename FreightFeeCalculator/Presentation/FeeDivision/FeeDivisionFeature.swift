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
        case total, count
    }
    
    struct FormattedFee: Identifiable, Equatable {
        let id = UUID()
        let key: UInt
        let value: Int
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
        var count: String = ""
        var mode: DividingMode = .byThousand
        var calculationResult: FeeCombination?
        var keyboardFocus: KeyboardFocus?
        
        var isCalculateButtonDisabled: Bool { UInt(total) == nil || Int(count) == nil }
        var formattedResult: [FormattedFee] {
            guard let fees = calculationResult?.fees else { return [] }
            let sorted = fees.sorted {
                guard $0.value != $1.value else { return $0.key < $1.key }
                return $0.value > $1.value
            }
            
            return sorted.map { FormattedFee(key: $0.key, value: $0.value) }
        }
    }
    
    @CasePathable
    enum Action: BindableAction {
        enum ViewAction {
            case calculateButtonTapped
            case dismissKeyboard
        }
        
        enum InnerAction {
            case calculationResponse(Result<FeeCombination, Error>)
        }
        
        case view(ViewAction)
        case inner(InnerAction)
        case binding(BindingAction<State>)
    }
    
    @Dependency(\.feeCalculationClient) var feeCalculationClient
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .view(.calculateButtonTapped):
                state.calculationResult = nil
                state.errorMessage = nil
                
                
                guard let total = UInt(state.total), let count = Int(state.count), total > .zero, count > .zero else {
                    state.errorMessage = "잘못된 값 입력"
                    return .none
                }
                
                let mode = state.mode
                return .run { send in
                    await send(.inner(.calculationResponse(Result {
                        try await feeCalculationClient.calculateFee(total, count, mode)
                    })))
                }
                .cancellable(id: CancelID.calculate)
                
            case .view(.dismissKeyboard):
                state.keyboardFocus = nil
                return .none
                
            case .inner(.calculationResponse(.success(let combination))):
                state.calculationResult = combination
                state.errorMessage = nil
                return .none
                
            case .inner(.calculationResponse(.failure(let error))):
                state.errorMessage = error.localizedDescription
                return .none
                
            case .binding(\.total), .binding(\.count):
                state.calculationResult = nil
                state.errorMessage = nil
                return .cancel(id: CancelID.calculate)
                
            case .binding:
                return .none
            }
        }
    }
}
