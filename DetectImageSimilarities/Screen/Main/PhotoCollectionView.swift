//
//  ContentView.swift
//  DetectImageSimilarities
//
//  Created by Melih Çulha on 26.10.2023.
//

import SwiftUI
import Photos

struct PhotoCollectionView: View {
    @State private var viewModel: PhotoCollectionViewModel = .init()
    
    private let columns: [GridItem] = [
        GridItem(.fixed(120)),
        GridItem(.fixed(120)),
        GridItem(.fixed(120))
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(viewModel.imageAssets, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .scaledToFit()
                                
                            
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Photos")
        }
        .task {
            await viewModel.requestPhotoAccess()
        }
    }
}

#Preview {
    PhotoCollectionView()
}
