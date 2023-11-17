//
//  ImageModel.swift
//  DetectImageSimilarities
//
//  Created by Melih Çulha on 13.11.2023.
//

import Foundation
import UIKit

struct ImageModel: Identifiable {
    let id: UUID = UUID()
    var images: [ImageProcessModel]
    let thumbnail: UIImage
}
