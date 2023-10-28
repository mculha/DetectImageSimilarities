//
//  PhotoCollection.swift
//  DetectImageSimilarities
//
//  Created by Melih Çulha on 29.10.2023.
//

import Photos

final class PhotoCollection: NSObject, ObservableObject {
    
    var albumName: String?
    var smartAlbulType: PHAssetCollectionType?
    let cache = CachedImageManager()
    
}
