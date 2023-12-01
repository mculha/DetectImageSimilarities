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
        Color(red: 197/255, green: 232/255, blue: 183/255),
        Color(red: 171/255, green: 224/255, blue: 152/255),
        Color(red: 131/255, green: 212/255, blue: 117/255),
        Color(red: 87/255, green: 200/255, blue: 77/255),
        Color(red: 46/255, green: 182/255, blue: 44/255),
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
