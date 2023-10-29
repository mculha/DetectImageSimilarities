//
//  PhotoAssetCollection.swift
//  DetectImageSimilarities
//
//  Created by Melih Çulha on 29.10.2023.
//

import Foundation
import Photos

class PhotoAssetCollection: RandomAccessCollection {
    private(set) var fetchResult: PHFetchResult<PHAsset>
    private var iteratorIndex: Int = 0
    
    private var cache = [Int : PhotoAsset]()
    
    var startIndex: Int { 0 }
    var endIndex: Int { fetchResult.count }
    let queue = DispatchQueue(label: "queue_cache") // serial queue

    init(_ fetchResult: PHFetchResult<PHAsset>) {
        self.fetchResult = fetchResult
    }

    subscript(position: Int) -> PhotoAsset {
        queue.sync {
            if let asset = cache[position] {
                return asset
            }
            let asset = PhotoAsset(phAsset: fetchResult.object(at: position), index: position)
            self.cache[position] = asset
            return asset
        }
    }
    
    var phAssets: [PHAsset] {
        var assets = [PHAsset]()
        fetchResult.enumerateObjects { (object, count, stop) in
            assets.append(object)
        }
        return assets
    }
}

extension PhotoAssetCollection: Sequence, IteratorProtocol {

    func next() -> PhotoAsset? {
        if iteratorIndex >= count {
            return nil
        }
        
        defer {
            iteratorIndex += 1
        }
        
        return self[iteratorIndex]
    }
}
