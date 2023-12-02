//
//  ProcessStatus.swift
//  DetectImageSimilarities
//
//  Created by Melih Çulha on 30.11.2023.
//

import Foundation

enum ProcessStatus: Equatable {
    case ready
    case processing(progress: Int)
    case finished
    
    var title: String {
        switch self {
        case .ready:
            return "Ready to Start"
        case .processing(let progress):
            return progress == 0 ? "Starting" : "Processing"
        case .finished:
            return ""
        }
    }
}
