//
//  ImageModel.swift
//  DetectImageSimilarities
//
//  Created by Melih Çulha on 13.11.2023.
//

import Foundation
import UIKit

class ImageModel: Identifiable {
    let id: UUID = UUID()
    var imageIds: Set<UUID> = .init()
    var images: [ImageProcessModel]
    let thumbnail: UIImage
    
    init(imageIds: Set<UUID>, images: [ImageProcessModel], thumbnail: UIImage) {
        self.imageIds = imageIds
        self.images = images
        self.thumbnail = thumbnail
    }
}
