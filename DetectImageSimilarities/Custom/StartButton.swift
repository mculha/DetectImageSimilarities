//
//  StartButton.swift
//  DetectImageSimilarities
//
//  Created by Melih Çulha on 30.11.2023.
//

import SwiftUI

struct StartButton: View {
    
    @State private var wave = false
    private let duration: TimeInterval = 2.0
    
    var body: some View {
        ZStack {

            Circle()
                .stroke(lineWidth: 1)
                .frame(width: 150, height: 150)
                .foregroundStyle(.blue)
                .scaleEffect(wave ? 1.5 : 1)
                .opacity(wave ? 0 : 1)
                .animation(.easeInOut(duration: duration).repeatForever(autoreverses: false), value: wave)
            
            Circle()
                .stroke(lineWidth: 1)
                .frame(width: 150, height: 150)
                .foregroundStyle(.blue)
                .scaleEffect(wave ? 1.5 : 1)
                .opacity(wave ? 0 : 1)
                .animation(.easeInOut(duration: duration).repeatForever(autoreverses: false).delay(0.5), value: wave)
            
            
            Circle()
                .frame(width: 150, height: 150)
                .foregroundStyle(.blue)
                .shadow(radius: 25)
            
            Text("Start")
                .font(.system(size: 25))
                .fontWeight(.bold)
                .foregroundStyle(.white)
        }
        .frame(width: 150, height: 150)
        .onAppear {
            self.wave.toggle()
        }
    }
}

#Preview {
    StartButton()
        .previewLayout(.sizeThatFits)
}
