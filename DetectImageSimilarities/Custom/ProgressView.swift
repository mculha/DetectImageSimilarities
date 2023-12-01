//
//  ProgressView.swift
//  DetectImageSimilarities
//
//  Created by Melih Çulha on 1.12.2023.
//

import Foundation
import SwiftUI

struct ProgressView: View {
    
    var value: Int
    private let range: ClosedRange<Double> = 0...100
    
    var body: some View {
        Gauge(value: Double(value), in: range) {
            Image(systemName: "gauge.with.dots.needle.bottom.50percent")
                .font(.system(size: 50.0))
        } currentValueLabel: {
            Text("\(Int(value))")
        }
        .gaugeStyle(SpeedometerStyle())
    }
}

#Preview {
    ProgressView(value: 100)
}
