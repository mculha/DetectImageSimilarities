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
}
