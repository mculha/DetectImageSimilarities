//
//  ImageModel.swift
//  DetectImageSimilarities
//
//  Created by Melih Çulha on 8.11.2023.
//

import Foundation
import UIKit
import Vision
import PhotosUI

class ImageProcessModel: Identifiable {
    let id: UUID = UUID()
    let image: UIImage
    var observation: VNFeaturePrintObservation? = nil
    var sameImageIds: Set<UUID> = .init()
    var asset: PHAsset
    
    var creationDate: Date? {
        return asset.creationDate
    }
    
    init(image: UIImage, asset: PHAsset, observation: VNFeaturePrintObservation? = nil) {
        self.image = image
        self.asset = asset
        self.observation = observation
    }
}

extension ImageProcessModel: Equatable {
    
    static func == (lhs: ImageProcessModel, rhs: ImageProcessModel) -> Bool {
        return lhs.id == rhs.id
    }
    
}
