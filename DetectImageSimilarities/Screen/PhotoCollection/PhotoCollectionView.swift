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
    
    private let columns: [GridItem] = [
        GridItem(.flexible(minimum: 40)),
        GridItem(.flexible(minimum: 40)),
        GridItem(.flexible(minimum: 40))
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                        ForEach(Array(viewModel.photos), id: \.id) { model in
                            NavigationLink {
                                PhotoCollectionDetailView(viewModel: .init(imageModel: model))
                            } label: {
                                PhotoView(model: model)
                            }
                        }
                    }
                }
                
                Button {
                    self.viewModel.fetchPhotoAssets()
                } label: {
                    Text("Start")
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(Color(.appPrimary))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .allowsHitTesting(viewModel.state == .ready)
            }
            .padding()
            .navigationTitle(viewModel.state.title)
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $viewModel.presentPermissionRequired) {
                PermissionView()
            }
            .onAppear {
                Task {
                    await viewModel.requestPhotoAccess()
                }
            }
        }
        
    }
}

#Preview {
    PhotoCollectionView()
}

struct PhotoView: View {
    
    let model: ImageModel
    
    var body: some View {
        GeometryReader { gp in
            Image(uiImage: model.thumbnail)
                .resizable()
                .scaledToFill()
                .frame(height: gp.size.width)
        }
        .clipped()
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}
