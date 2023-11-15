//
//  PhotosPermission.swift
//  DetectImageSimilarities
//
//  Created by Melih Çulha on 27.10.2023.
//

import Foundation
import Photos

final class PhotosPermission: PermissionProtocol {
    
    func requestAuthorization() async -> AuthorizationStatus {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if status == .authorized {
            return .authorized
        } else if status == .limited {
            return .limited
        } else if status == .notDetermined {
            let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            return status == .authorized ? .authorized : .denied
        } else {
            return .denied
        }
    }
}
