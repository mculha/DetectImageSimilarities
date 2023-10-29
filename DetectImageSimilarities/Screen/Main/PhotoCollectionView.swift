//
//  ContentView.swift
//  DetectImageSimilarities
//
//  Created by Melih Çulha on 26.10.2023.
//

import SwiftUI
import Photos

struct PhotoCollectionView: View {
    @StateObject private var viewModel: PhotoCollection = PhotoCollection(smartAlbum: .smartAlbumUserLibrary)

    
    @Environment(\.displayScale) private var displayScale
    private static let itemSpacing = 12.0
    private static let itemCornerRadius = 15.0
    private static let itemSize = CGSize(width: 90, height: 90)
    
    private var imageSize: CGSize {
        return CGSize(width: Self.itemSize.width * min(displayScale, 2), height: Self.itemSize.height * min(displayScale, 2))
    }
    
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: itemSize.width, maximum: itemSize.height), spacing: itemSpacing)
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: Self.itemSpacing) {
                        ForEach(viewModel.photoAssets) { asset in
                            PhotoItemView(asset: asset, cache: viewModel.cache, imageSize: imageSize)
                                .frame(width: Self.itemSize.width, height: Self.itemSize.height)
                                .clipped()
                                .cornerRadius(Self.itemCornerRadius)
                                .onAppear {
                                    Task {
                                        await viewModel.cache.startCaching(for: [asset], targetSize: imageSize)
                                    }
                                }
                                .onDisappear {
                                    Task {
                                        await viewModel.cache.stopCaching(for: [asset], targetSize: imageSize)
                                    }
                                }
                        }
                    }
                }
            }
            .task {
                await viewModel.loadPhotos()
                await viewModel.loadThumbnail()
            }
            .padding()
            .navigationTitle("Photos")
        }
    }
}

#Preview {
    PhotoCollectionView()
}
