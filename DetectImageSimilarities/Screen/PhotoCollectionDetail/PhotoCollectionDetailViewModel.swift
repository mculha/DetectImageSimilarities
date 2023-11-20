//
//  PhotoCollectionDetailViewModel.swift
//  DetectImageSimilarities
//
//  Created by Melih Çulha on 20.11.2023.
//

import Foundation

@Observable
final class PhotoCollectionDetailViewModel {
    
    let imageModel: ImageModel
    
    init(imageModel: ImageModel) {
        self.imageModel = imageModel
    }
    
}
