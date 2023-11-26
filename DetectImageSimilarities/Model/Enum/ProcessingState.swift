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
            return String(format: "Fetching Photos %d/%d", fetched, total)
        case .preparing(let prepared, let total):
            return String(format: "Preparing Photos %d/%d", prepared, total)
        case .processing(let processed, let total):
            return String(format: "Processing Photos %d/%d", processed, total)
        }
    }
}
