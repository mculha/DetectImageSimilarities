//
//  ProcessingState.swift
//  DetectImageSimilarities
//
//  Created by Melih Çulha on 13.11.2023.
//

import Foundation

enum ProcessingState: Equatable {
    case permissionRequired
    case ready
    case fetchingPhotos(fetched: Int, total: Int)
    case preparing(prepared: Int, total: Int)
    case processing(processed: Int, total: Int)
    case empty
    case done
    case error(message: String)
    
    var title: String {
        switch self {
        case .permissionRequired, .ready, .empty, .done, .error:
            return "Photos"
        case .fetchingPhotos(let fetched, let total):
            let percentage: Int = (100 * fetched) / total
            return String(format: "Fetching Photos %d%%", percentage)
        case .preparing(let prepared, let total):
            let percentage: Int = (100 * prepared) / total
            return String(format: "Preparing Photos %d%%", percentage)
        case .processing(let processed, let total):
            let percentage: Int = (100 * processed) / total
            return String(format: "Processing Photos %d%%", percentage)
        }
    }
}
