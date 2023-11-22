//
//  ImageModel.swift
//  DetectImageSimilarities
//
//  Created by Melih Çulha on 8.11.2023.
//

import Foundation
import UIKit
import Vision

class ImageProcessModel: Identifiable {
    let id: UUID = UUID()
    let image: UIImage
    let creationDate: Date?
    var observation: VNFeaturePrintObservation? = nil
    var sameImageIds: Set<UUID> = .init()
    
    init(image: UIImage, creationDate: Date?, observation: VNFeaturePrintObservation? = nil) {
        self.image = image
        self.creationDate = creationDate
        self.observation = observation
    }
}

extension ImageProcessModel: Equatable {
    
    static func == (lhs: ImageProcessModel, rhs: ImageProcessModel) -> Bool {
        return lhs.id == rhs.id
    }
    
}
