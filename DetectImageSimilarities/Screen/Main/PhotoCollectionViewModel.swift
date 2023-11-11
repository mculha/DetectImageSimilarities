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
            refreshPhotoAssets()
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
        var images: [ImageModel] = []
        
        newFetchResult.enumerateObjects { asset, _, _ in
            if let imageModel = self.loadImage(from: asset) {
                images.append(imageModel)
            }

        }
        let concurrentQueue = DispatchQueue(label: "concurrentQueue", attributes: .concurrent)
        let subImageArrays = images.splitInSubArrays(into: 4)
        
        for subImageArray in subImageArrays {
            concurrentQueue.async {
                for imageModel in subImageArray {
                    imageModel.observation = self.observation(image: imageModel.image)
                }
            }
        }
        
        concurrentQueue.sync(flags: .barrier) {
            self.findSimilarities(images: images)
        }
        
    }
    
    private func findSimilarities(images: [ImageModel]) {
        let concurrentQueue = DispatchQueue(label: "concurrentQueue", attributes: .concurrent)

        print("Deneme \(images.count)")

        let source = images.first!
        let subArrays = images.splitInSubArrays(into: 2)
        for (subArrayIndex, subArray) in subArrays.enumerated() {
            concurrentQueue.async {
                for index in 0..<subArray.count {
                    let destinationImage = images[index]
                    
                    let distance = self.findDistance(source: source.observation, destination: destinationImage.observation)
                    print("Deneme Distance - \(subArrayIndex): \(distance)")
                }
            }
        }

//        concurrentQueue.async {
//            for index in 1..<subArrays[0].count {
//                let destinationImage = images[index]
//                
//                let distance = self.findDistance(source: destinationImage.observation, destination: image.observation)
//                print("Deneme Distance - 1: \(distance)")
//            }
//        }
//        
//        concurrentQueue.async {
//            for index in 1..<subArrays[1].count {
//                let destinationImage = images[index]
//                
//                let distance = self.findDistance(source: destinationImage.observation, destination: image.observation)
//                print("Deneme Distance - 2: \(distance)")
//            }
//        }
        
//        for imageGroup in images {
//            for i in 0..<imageGroup.count {
//                for j in (i + 1)..<imageGroup.count {
//                    concurrentQueue.async {
//                        let distance = self.findDistance(source: imageGroup[i].image, destination: imageGroup[j].image, i: i, j: j)
//                        print("Deneme Distance: \(distance) - i:\(i) - j:\(j)")
//                    
//                    }
//                    
//                }
//            }
//        }
        
        concurrentQueue.sync(flags: .barrier) {
            print("Deneme Finished All Tasks ")
            
        }
        
//        for i in 0..<100 {
//            print("Deneme i has been Changed to \(i + 1)")
//            
//            for j in (i + 1)..<100 {
//                Task {
//                    let distance = await findDistance(source: images[i].image, destination: images[j].image, i: i, j: j)
//                    print("Deneme Distance: \(distance) - i:\(i) - j:\(j)")
//                }
//            }
//        }
//        group.wait()
//        group.notify(queue: DispatchQueue.main) {
//            print("Deneme All tasks have completed")
//        }
        

    }
    
    private func findDistance(source: VNFeaturePrintObservation?, destination: VNFeaturePrintObservation?) -> Float {
        guard let source, let destination else { return 100.0 }
        var distance = Float(0)
        try? destination.computeDistance(&distance, to: source)
        return distance
    }
}

extension Array {
    func splitInSubArrays(into size: Int) -> [[Element]] {
        return (0..<size).map {
            stride(from: $0, to: count, by: size).map { self[$0] }
        }
    }
}
