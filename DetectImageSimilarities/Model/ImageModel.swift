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
    var images: [ImageProcessModel]
    let thumbnail: UIImage
    
    init(images: [ImageProcessModel], thumbnail: UIImage) {
        self.images = images
        self.thumbnail = thumbnail
    }
}

extension ImageModel: Equatable {
    
    static func == (lhs: ImageModel, rhs: ImageModel) -> Bool {
        return lhs.id == rhs.id
    }
}
