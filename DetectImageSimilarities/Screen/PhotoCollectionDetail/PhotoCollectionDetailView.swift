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
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    PhotoCollectionDetailView(viewModel: .init(imageModel: .init(images: [], thumbnail: UIImage())))
}
