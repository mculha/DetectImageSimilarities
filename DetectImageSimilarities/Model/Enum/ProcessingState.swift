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
    case preparing
    case processing(percentage: Int)
    case done
    case error(message: String)
}
