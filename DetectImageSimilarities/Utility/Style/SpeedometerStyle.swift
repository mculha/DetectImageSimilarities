//
//  SpeedometerStyle.swift
//  DetectImageSimilarities
//
//  Created by Melih Çulha on 1.12.2023.
//

import Foundation
import SwiftUI

struct SpeedometerStyle: GaugeStyle {
    
    private let gradient = LinearGradient(gradient: Gradient(colors: [
        Color(.gradientSpeedometer1),
        Color(.gradientSpeedometer2),
        Color(.gradientSpeedometer3),
        Color(.gradientSpeedometer4),
        Color(.gradientSpeedometer5)
    ]), startPoint: .trailing, endPoint: .leading)

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .foregroundColor(Color(.systemGray6))
            
            Circle()
                .trim(from: 0, to: 0.75 * configuration.value)
                .stroke(gradient, lineWidth: 20)
                .rotationEffect(.degrees(135))
            
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(Color.black, style: StrokeStyle(lineWidth: 10, lineCap: .butt, lineJoin: .round, dash: [1, 10], dashPhase: 0.0))
                .rotationEffect(.degrees(135))
            
            HStack {
                configuration.currentValueLabel
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                    
                Text("%")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .bold()
                    .foregroundColor(.gray)
                
            }
        }
        .frame(width: 150, height: 150)
        
    }
}
