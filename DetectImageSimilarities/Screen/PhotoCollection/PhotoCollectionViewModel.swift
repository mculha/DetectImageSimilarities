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
    var status: ProcessStatus = .ready
    var startTitleAnimation: Bool = true
    
    var presentPermissionRequired: Bool = false
    @ObservationIgnored
    private var photosPermission: PermissionProtocol = PhotosPermission()
    @ObservationIgnored
    private var smartAlbumType: PHAssetCollectionSubtype
    @ObservationIgnored
    private var fetchResult = PHFetchResult<PHAsset>()
    @ObservationIgnored
    var images: [UUID: ImageProcessModel] = [:]
    
    @ObservationIgnored
    let readyID: String = "ready"
    @ObservationIgnored
    let progressID: String = "progress"
    @ObservationIgnored
    let finishedID: String = "finished"
    
    private var total = 0
    var progress: Int = 0 {
        didSet {
            let value = (progress * 100) / total
            self.status = .processing(progress: value)
        }
    }
    
    init(smartAlbum smartAlbumType: PHAssetCollectionSubtype) {
        self.smartAlbumType = smartAlbumType
    }
    
    func requestPhotoAccess() async {
        let status = await photosPermission.requestAuthorization()
        
        if status == .denied {
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
                imageModel = ImageProcessModel(image: result, asset: asset)
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
    
    func fetchPhotoAssets() {
        self.status = .processing(progress: 0)
        let photosQueue = DispatchQueue(label: "photosQueue")
        photosQueue.asyncAfter(deadline: .now() + 2) {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let newFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            self.total = newFetchResult.count * 3
            newFetchResult.enumerateObjects { asset, _, _ in
                if let imageModel = self.loadImage(from: asset) {
                    self.images[imageModel.id] = imageModel
                }
                self.progress += 1
            }
            guard !self.images.isEmpty else {
                self.status = .finished
                return
            }
            
            let queue = DispatchQueue(label: "concurrentQueue", attributes: .concurrent)
            let subImageArrays = Array(self.images.values).splitInSubArrays(into: 4)
            
            for subImageArray in subImageArrays {
                queue.async {
                    for imageModel in subImageArray {
                        imageModel.observation = self.observation(image: imageModel.image)
                        self.progress += 1
                    }
                }
            }
            
            queue.sync(flags: .barrier) {
                self.findSimilarities(images: Array(self.images.values))
            }
        }
    }
    
    private func findSimilarities(images: [ImageProcessModel]) {
        for firstIndex in 0..<images.count {
            for secondIndex in (firstIndex + 1)..<images.count {
                let destination = images[secondIndex]
                let source = images[firstIndex]
                
                
                let distance = self.findDistance(source: source.observation, destination: destination.observation)
                if distance == 0 {
                    source.sameImageIds.insert(destination.id)
                    destination.sameImageIds.insert(source.id)
                }
                
            }
            self.progress += 1
        }
        self.progress = self.total
        let filteredImageArray = self.images.filter { !$0.value.sameImageIds.isEmpty }
            .map { key, value in
                var set: Set<UUID> = value.sameImageIds
                set.insert(key)
                return set
            }
        
        let filteredImages = Array(Set(filteredImageArray))
        for imageIDs in filteredImages {
            var processModels: [ImageProcessModel] = []
            for imageID in imageIDs {
                if let processImage = self.images[imageID] {
                    processModels.append(processImage)
                }
            }
            self.photos.append(.init(images: processModels, thumbnail: processModels.first!.image))
        }
        self.status = .finished
        
    }
    
    private func findDistance(source: VNFeaturePrintObservation?, destination: VNFeaturePrintObservation?) -> Float {
        guard let source, let destination else { return 100.0 }
        var distance = Float(0)
        try? destination.computeDistance(&distance, to: source)
        return distance
    }
}
