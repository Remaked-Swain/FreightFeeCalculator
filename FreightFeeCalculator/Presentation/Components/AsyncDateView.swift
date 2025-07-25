//
//  AsyncDateView.swift
//  FreightFeeCalculator
//
//  Created by Swain Yun on 7/19/25.
//

import SwiftUI

struct AsyncDateView: View {
    @State private var text: String = String()
    @Binding var date: Date?
    
    private let format: DateFormat
    private let prompt: String
    
    init(
        date: Binding<Date?>,
        format: DateFormat,
        prompt: String
    ) {
        self._date = date
        self.format = format
        self.prompt = prompt
    }
    
    init(
        date: Date?,
        format: DateFormat,
        prompt: String
    ) {
        self.init(date: .constant(date), format: format, prompt: prompt)
    }
    
    var body: some View {
        Text(text)
            .task {
                text = await date?.toString(by: format) ?? prompt
            }
            .onChange(of: date) { _, newValue in
                Task { @MainActor in
                    text = await newValue?.toString(by: format) ?? prompt
                }
            }
    }
}
