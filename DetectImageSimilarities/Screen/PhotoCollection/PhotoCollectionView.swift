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
        if case .ready = viewModel.status {
            VStack(spacing: 60) {
                Text(viewModel.status.title)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.blue)
                
                Button(action: self.viewModel.fetchPhotoAssets) {
                    StartButton()
                }
                
            }
            .id(viewModel.readyID)
            .transition(.scale.animation(.easeInOut))
            
        } else if case let .processing(progress) = viewModel.status {
            VStack(spacing: 60) {
                Text(viewModel.status.title)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.blue)
                    .opacity(viewModel.startTitleAnimation ? 0.1 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(), value: viewModel.startTitleAnimation)
                
                ProgressView(value: progress)
                
            }
            .id(viewModel.progressID)
            .transition(.scale.animation(.easeInOut))
            .onAppear {
                viewModel.startTitleAnimation.toggle()
            }
        } else {
            NavigationStack {
                VStack {
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                            ForEach(Array(viewModel.photos), id: \.id) { model in
                                NavigationLink(destination: PhotoCollectionDetailView(viewModel: .init(imageModel: model))) {
                                    PhotoView(model: model)
                                }
                            }
                        }
                    }
                }
                .padding()
                .navigationTitle("Duplicate Photos")
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
            .id(viewModel.finishedID)
            .transition(.scale.animation(.easeInOut))
        }
    }
}

#Preview {
    PhotoCollectionView()
}

struct PhotoView: View {
    
    let model: ImageModel
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            GeometryReader { gp in
                
                Image(uiImage: model.thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(height: gp.size.width)
            }
            
            Text(String(model.images.count))
                .font(.system(size: 10))
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .background(.black.opacity(0.5))
                .clipShape(Circle())
                .padding([.bottom, .trailing], 5)
        }
        .clipped()
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .shadow(radius: 1)
    }
}
