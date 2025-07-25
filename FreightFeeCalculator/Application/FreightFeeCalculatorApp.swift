//
//  FreightFeeCalculatorApp.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/8/25.
//

import SwiftUI
import Swinject

@main
struct FreightFeeCalculatorApp: App {
    private let resolver: Resolver = {
        let assembler = Assembler([
            InfrastructureAssembly(),
            RepositoryAssembly(),
            DomainAssembly(),
            PresentationAssembly()
        ])
        return assembler.resolver
    }()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView(resolver: resolver)
            }
        }
    }
}
