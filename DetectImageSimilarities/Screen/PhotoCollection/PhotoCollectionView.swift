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

    
    var body: some View {
        if case .ready = viewModel.status {
            ReadyForProcessView(title: viewModel.status.title, startAction: viewModel.fetchPhotoAssets)
        } else if case let .processing(progress) = viewModel.status {
            ProcessingView(title: viewModel.status.title, startTitleAnimation: $viewModel.startTitleAnimation, progress: progress)
        } else {
            ResultView(photos: viewModel.photos)
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
        .clipShape(RoundedRectangle(cornerRadius: 1))
    }
}

struct ReadyForProcessView: View {
    let title: String
    let startAction: () -> ()
    
    private let id: String = "ready"
    
    var body: some View {
        VStack(spacing: 60) {
            Text(title)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.blue)
            
            Button(action: startAction) {
                StartButton()
            }
            
        }
        .id(self.id)
        .transition(.scale.animation(.easeInOut))
    }
}

struct ProcessingView: View {
    let title: String
    @Binding var startTitleAnimation: Bool
    var progress: Int
    
    private let id: String = "processing"
    
    var body: some View {
        VStack(spacing: 60) {
            Text(title)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.blue)
                .opacity(startTitleAnimation ? 0.1 : 1.0)
                .animation(.easeInOut(duration: 1.0).repeatForever(), value: startTitleAnimation)
            
            ProgressView(value: progress)
            
        }
        .id(id)
        .transition(.scale.animation(.easeInOut))
        .onAppear {
            startTitleAnimation.toggle()
        }
    }
}

struct ResultView: View {
    
    private let columns: [GridItem] = [
        GridItem(.flexible(minimum: 40), spacing: 2),
        GridItem(.flexible(minimum: 40), spacing: 2),
        GridItem(.flexible(minimum: 40), spacing: 2)
    ]
    
    let photos: [ImageModel]
    let id: String = "result"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, alignment: .center, spacing: 2) {
                        ForEach(Array(photos), id: \.id) { model in
                            NavigationLink(destination: PhotoCollectionDetailView(viewModel: .init(imageModel: model))) {
                                PhotoView(model: model)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 0)
            .navigationTitle("Duplicate Photos")
            .navigationBarTitleDisplayMode(.automatic)
            
        }
        .id(id)
        .transition(.scale.animation(.easeInOut))
    }
}
