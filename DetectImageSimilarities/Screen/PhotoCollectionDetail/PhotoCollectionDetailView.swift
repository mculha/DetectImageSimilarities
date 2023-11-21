//
//  PhotoCollectionDetailView.swift
//  DetectImageSimilarities
//
//  Created by Melih Çulha on 20.11.2023.
//

import SwiftUI

struct PhotoCollectionDetailView: View {
    
    let viewModel: PhotoCollectionDetailViewModel
    
    var body: some View {
        Text("Number of Images: \(viewModel.imageModel.imageIds.count)")
    }
}

#Preview {
    PhotoCollectionDetailView(viewModel: .init(imageModel: .init(imageIds: [], images: [], thumbnail: UIImage())))
}
