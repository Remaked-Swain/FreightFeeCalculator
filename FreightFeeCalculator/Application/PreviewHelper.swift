//
//  PreviewHelper.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/19/25.
//

import Foundation
import Swinject

final class PreviewHelper {
    static let shared = PreviewHelper()
    
    let resolver: Resolver = {
        let assembler = Assembler([
            InfrastructureAssembly(),
            RepositoryAssembly(),
            DomainAssembly(),
            PresentationAssembly()
        ])
        return assembler.resolver
    }()
    
    private init() { }
}
