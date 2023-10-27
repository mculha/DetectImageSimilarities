//
//  MainViewModel.swift
//  DetectImageSimilarities
//
//  Created by Melih Çulha on 27.10.2023.
//

import Foundation
import Photos
import UIKit

@Observable final class MainViewModel {
    
    var imageAssets: [UIImage] = []
    var photosPermission: PermissionProtocol = PhotosPermission()
    
    func requestPhotoAccess() async {
        
        
        let status = await photosPermission.requestAuthorization()
        
        if status == .authorized {
            self.fetchImages()
        } else {
            //TODO Handle denied case
        }
    }
    
    private func fetchImages() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        assets.enumerateObjects { asset, _, _ in
            self.imageAssets.append(self.loadImage(from: asset))
        }
    }
    
    func loadImage(from asset: PHAsset) -> UIImage {
        let imageManager = PHImageManager.default()
        let targetSize = CGSize(width: 100, height: 100)
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        
        var image: UIImage = UIImage()
        
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { result, _ in
            if let result = result {
                image = result
            }
        }
        
        return image
    }
}
