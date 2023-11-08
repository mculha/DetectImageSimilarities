//
//  ImageModel.swift
//  DetectImageSimilarities
//
//  Created by Melih Çulha on 8.11.2023.
//

import Foundation
import UIKit

struct ImageModel {
    let id: UUID = UUID()
    let image: UIImage
    let creationDate: Date?
}
