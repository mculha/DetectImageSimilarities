//
//  ContentView.swift
//  DetectImageSimilarities
//
//  Created by Melih Çulha on 26.10.2023.
//

import SwiftUI
import Photos

struct PhotoCollectionView: View {
    @State private var viewModel: PhotoCollectionViewModel = .init(smartAlbum: .smartAlbumUserLibrary)
    
    
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
                        ForEach(Array(viewModel.photos), id: \.id) { model in
                            
                            NavigationLink {
                                PhotoCollectionDetailView(viewModel: .init(imageModel: model))
                            } label: {
                                Image(uiImage: model.thumbnail)
                                    .frame(width: Self.itemSize.width, height: Self.itemSize.height)
                                    .clipped()
                                    .cornerRadius(Self.itemCornerRadius)
                                
                            }
                            
                        }
                    }
                }
            }
            .task {
                await viewModel.requestPhotoAccess()
            }
            .padding()
            .navigationTitle("Photos")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $viewModel.presentPermissionRequired) {
                PermissionView()
            }
        }
        
    }
}

#Preview {
    PhotoCollectionView()
}
