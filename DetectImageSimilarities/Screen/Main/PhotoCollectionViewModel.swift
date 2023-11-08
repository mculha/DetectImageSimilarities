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
        
    var similarPhotos: [UIImage] = []
    
    @ObservationIgnored
    private var photosPermission: PermissionProtocol = PhotosPermission()
    @ObservationIgnored
    private var smartAlbumType: PHAssetCollectionSubtype
    @ObservationIgnored
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
    
    func loadImage(from asset: PHAsset) -> ImageModel? {
        let imageManager = PHImageManager.default()
        let targetSize = CGSize(width: 300, height: 300)
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        
        var imageModel: ImageModel?
        
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { result, _ in
            if let result {
                imageModel = ImageModel(image: result, creationDate: asset.creationDate)
            }
        }
        
        return imageModel
    }
    
    private func refreshPhotoAssets(_ fetchResult: PHFetchResult<PHAsset>? = nil) async {
        var newFetchResult = fetchResult
        
        if newFetchResult == nil {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            newFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        }
        
        if let newFetchResult {
            var images: [ImageModel?] = []
            newFetchResult.enumerateObjects { asset, _, _ in images.append(self.loadImage(from: asset)) }
            self.findSimilarities(images: images.compactMap { $0 })
        }
    }
    
    private func findSimilarities(images: [ImageModel]) {
        for i in 0..<100 {
            print("Deneme i has been Changed to \(i + 1)")

            for j in (i + 1)..<100 {
                let sourceImage = images[i].image
                let destinationImage = images[j].image
                let sourceObservation = observation(for: sourceImage)!
                let destinationObservation = observation(for: destinationImage)!
                
                var distance = Float(0)
                try? destinationObservation.computeDistance(&distance, to: sourceObservation)
                if distance < 0.2 {
                    similarPhotos.append(destinationImage)
                    similarPhotos.append(sourceImage)
                }
            }
            
        }
    }
    
    func observation(for image: UIImage) -> VNFeaturePrintObservation? {
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        let request = VNGenerateImageFeaturePrintRequest()
        try? requestHandler.perform([request])
        return request.results?.first as? VNFeaturePrintObservation
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
