//
//  PermissionProtocol.swift
//  DetectImageSimilarities
//
//  Created by Melih Çulha on 27.10.2023.
//

import Foundation

protocol PermissionProtocol {
    
    func requestAuthorization() async -> AuthorizationStatus
    
}

enum AuthorizationStatus {
    case authorized
    case denied
}
