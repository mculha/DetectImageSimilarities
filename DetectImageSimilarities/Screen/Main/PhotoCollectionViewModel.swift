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
        let concurrentQueue = DispatchQueue(label: "concurrentQueue", attributes: .concurrent)
        let group = DispatchGroup()
        
        for i in 0..<100 {
            print("Deneme i has been Changed to \(i + 1)")
            
            for j in (i + 1)..<100 {
                concurrentQueue.async(group: group) {
                    // Your synchronous code goes here
                    let sourceImage = images[i].image
                    let destinationImage = images[j].image
                    let sourceObservation = self.observation(for: sourceImage, i: i, j: j)
                    let destinationObservation = self.observation(for: destinationImage, i: i, j: j)
                    
                    if let sourceObservation, let destinationObservation {
                        var distance = Float(0)
                        try? destinationObservation.computeDistance(&distance, to: sourceObservation)
                        if distance < 0.2 {
                            self.similarPhotos.append(destinationImage)
                            self.similarPhotos.append(sourceImage)
                        }
                    }
                    
                    print("Deneme i: \(i) - j: \(j)")
                    
                }
            }
        }
        group.wait()
        group.notify(queue: DispatchQueue.main) {
            print("Deneme All tasks have completed")
        }
        

    }
    
    
    private func observation(for image: UIImage, i: Int, j: Int) -> VNFeaturePrintObservation? {
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        let request = VNGenerateImageFeaturePrintRequest()
        DispatchQueue.main.async {
            
            print("Deneme Before Perform i: \(i) - j: \(j)")
            try? requestHandler.perform([request])
            print("Deneme After Perform i: \(i) - j: \(j)")

        }
        return request.results?.first as? VNFeaturePrintObservation
    }
}
