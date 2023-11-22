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
        
    var photos: [ImageModel] = []
    var state: ProcessingState = .ready
    
    var presentPermissionRequired: Bool = false
    @ObservationIgnored
    private var photosPermission: PermissionProtocol = PhotosPermission()
    @ObservationIgnored
    private var smartAlbumType: PHAssetCollectionSubtype
    @ObservationIgnored
    private var fetchResult = PHFetchResult<PHAsset>()
    @ObservationIgnored
    var images: [UUID: ImageProcessModel] = [:]
    
    init(smartAlbum smartAlbumType: PHAssetCollectionSubtype) {
        self.smartAlbumType = smartAlbumType
    }
    
    func requestPhotoAccess() async {
        guard self.photos.isEmpty else { return }
        let status = await photosPermission.requestAuthorization()
        
        if status != .denied {
            self.refreshPhotoAssets()
        } else {
            self.state = .permissionRequired
            self.presentPermissionRequired = true
        }
    }
    
    func loadImage(from asset: PHAsset) -> ImageProcessModel? {
        let imageManager = PHImageManager.default()
        let targetSize = CGSize(width: 300, height: 300)
        
        let options = PHImageRequestOptions()
        options.version = .current
        options.resizeMode = .exact
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        
        var imageModel: ImageProcessModel?
        
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { result, _ in
            if let result {
                imageModel = ImageProcessModel(image: result, creationDate: asset.creationDate)
            }
        }
        
        return imageModel
    }
    
    private func observation(image: UIImage) -> VNFeaturePrintObservation? {
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        let request = VNGenerateImageFeaturePrintRequest()
        try? requestHandler.perform([request])
        return request.results?.first as? VNFeaturePrintObservation
    }
    
    private func refreshPhotoAssets(_ fetchResult: PHFetchResult<PHAsset>? = nil) {
        var newFetchResult = fetchResult
        
        if newFetchResult == nil {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            newFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        }
        
        guard  let newFetchResult else { return }
        newFetchResult.enumerateObjects { asset, _, _ in
            if let imageModel = self.loadImage(from: asset) {
                self.images[imageModel.id] = imageModel
            }
        }
        let queue = DispatchQueue(label: "concurrentQueue", attributes: .concurrent)
        let subImageArrays = Array(images.values).splitInSubArrays(into: 4)
        
        for subImageArray in subImageArrays {
            queue.async {
                for imageModel in subImageArray {
                    imageModel.observation = self.observation(image: imageModel.image)
                }
            }
        }
        
        queue.sync(flags: .barrier) {
            self.findSimilarities(images: Array(images.values))
        }
        
    }

    private func findSimilarities(images: [ImageProcessModel]) {
        let queue = DispatchQueue(label: "concurrentQueue", attributes: .concurrent)
        let synchronizeQueue = DispatchQueue(label: "synchronizeQueue")

        for firstIndex in 0..<images.count {
            queue.async {
                for secondIndex in (firstIndex + 1)..<images.count {
                    let destination = images[secondIndex]
                    let source = images[firstIndex]
                    
                    
                    let distance = self.findDistance(source: source.observation, destination: destination.observation)
                    if distance == 0 {
                        synchronizeQueue.async {
                            source.sameImageIds.insert(destination.id)
                            destination.sameImageIds.insert(source.id)
                        }
                    }
                }
            }
        }
        queue.sync(flags: .barrier) {
            let filteredImages = self.images.filter { !$0.value.sameImageIds.isEmpty }
            for filteredImage in filteredImages {
                let sameImages = filteredImages.filter { model in
                    var firstSet = model.value.sameImageIds
                    firstSet.insert(model.value.id)
                    
                    var secondSet = filteredImage.value.sameImageIds
                    secondSet.insert(filteredImage.value.id)
                    
                    return firstSet == secondSet
                }
                var processModels: [ImageProcessModel] = []
                for sameImage in sameImages {
                    processModels.append(sameImage.value)
                }
                if !processModels.isEmpty {
                    self.photos.append(.init(images: processModels, thumbnail: processModels.first!.image))
                }
            }
            
            
            print(self.photos)
        }
        
    }
    
    private func findDistance(source: VNFeaturePrintObservation?, destination: VNFeaturePrintObservation?) -> Float {
        guard let source, let destination else { return 100.0 }
        var distance = Float(0)
        try? destination.computeDistance(&distance, to: source)
        return distance
    }
}
