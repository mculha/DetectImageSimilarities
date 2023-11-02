//
//  MainViewModel.swift
//  DetectImageSimilarities
//
//  Created by Melih Çulha on 27.10.2023.
//

import Foundation
import Photos
import UIKit
import Vision

@Observable final class PhotoCollectionViewModel: NSObject {
    
    let photoCollection = PhotoCollection(smartAlbum: .smartAlbumUserLibrary)
    
    var imageAssets: [UIImage] = []
    var similarPhotos: [UIImage] = []
    private var photosPermission: PermissionProtocol = PhotosPermission()
    private var smartAlbumType: PHAssetCollectionSubtype
    private var fetchResult = PHFetchResult<PHAsset>()

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    init(smartAlbum smartAlbumType: PHAssetCollectionSubtype) {
        self.smartAlbumType = smartAlbumType
    }
    
    func requestPhotoAccess() async {
        let status = await photosPermission.requestAuthorization()
        
        if status == .authorized {
            Task {
                await refreshPhotoAssets()
            }
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
    
    private func refreshPhotoAssets(_ fetchResult: PHFetchResult<PHAsset>? = nil) async {
        var newFetchResult = fetchResult
        
        if newFetchResult == nil {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            newFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        }
        
        if let newFetchResult {
            newFetchResult.enumerateObjects { asset, _, _ in self.imageAssets.append(self.loadImage(from: asset)) }
            self.findSimilarities()
        }
    }
    
    private func findSimilarities() {
        for i in 0..<100 {
            print("Deneme i has been Changed to \(i + 1)")

            for j in (i + 1)..<100 {
                let sourceObservation = featureprintObservationForImage(image: imageAssets[i])!
                let image = imageAssets[j]
                let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
                let request = VNGenerateImageFeaturePrintRequest()
                do {
                    try requestHandler.perform([request])
                    let result = request.results?.first as? VNFeaturePrintObservation
                    var distance = Float(0)
                    try result?.computeDistance(&distance, to: sourceObservation)
                    if distance < 0.2 {
                        if !similarPhotos.contains(image) {
                            similarPhotos.append(image)
                        }
                        
                        if !similarPhotos.contains(imageAssets[i]) {
                            similarPhotos.append(imageAssets[i])
                        }
                    }
                    print("Deneme Distance \(distance)")
                } catch {
                    print("Deneme Error \(error.localizedDescription)")
                }
            }
            
        }
    }
    
    func featureprintObservationForImage(image: UIImage) -> VNFeaturePrintObservation? {
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        let request = VNGenerateImageFeaturePrintRequest()
        do {
            try requestHandler.perform([request])
            return request.results?.first as? VNFeaturePrintObservation
        } catch {
            print("Vision error: \(error)")
            return nil
        }
    }
    
}

extension PhotoCollectionViewModel: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        Task { @MainActor in
            guard let changes = changeInstance.changeDetails(for: fetchResult) else { return }
            await self.refreshPhotoAssets(changes.fetchResultAfterChanges)
        }
    }
}
