//
//  Extension+Array.swift
//  DetectImageSimilarities
//
//  Created by Melih Çulha on 11.11.2023.
//

import Foundation

extension Array {
    func splitInSubArrays(into size: Int) -> [[Element]] {
        return (0..<size).map {
            stride(from: $0, to: count, by: size).map { self[$0] }
        }
    }
}
