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
            ReadyForProcessView(title: viewModel.status.title, readyID: viewModel.readyID, startAction: viewModel.fetchPhotoAssets)
        } else if case let .processing(progress) = viewModel.status {
            ProcessingView(title: viewModel.status.title, startTitleAnimation: $viewModel.startTitleAnimation, progressID: viewModel.progressID, progress: progress)
        } else {
            ResultView(photos: viewModel.photos, finishedID: viewModel.finishedID)
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
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .shadow(radius: 1)
    }
}

struct ReadyForProcessView: View {
    let title: String
    let readyID: String
    let startAction: () -> ()
    
    var body: some View {
        VStack(spacing: 60) {
            Text(title)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.blue)
            
            Button(action: startAction) {
                StartButton()
            }
            
        }
        .id(readyID)
        .transition(.scale.animation(.easeInOut))
    }
}

struct ProcessingView: View {
    let title: String
    @Binding var startTitleAnimation: Bool
    let progressID: String
    var progress: Int
    
    var body: some View {
        VStack(spacing: 60) {
            Text(title)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.blue)
                .opacity(startTitleAnimation ? 0.1 : 1.0)
                .animation(.easeInOut(duration: 1.0).repeatForever(), value: startTitleAnimation)
            
            ProgressView(value: progress)
            
        }
        .id(progressID)
        .transition(.scale.animation(.easeInOut))
        .onAppear {
            startTitleAnimation.toggle()
        }
    }
}

struct ResultView: View {
    
    private let columns: [GridItem] = [
        GridItem(.flexible(minimum: 40)),
        GridItem(.flexible(minimum: 40)),
        GridItem(.flexible(minimum: 40))
    ]
    
    let photos: [ImageModel]
    let finishedID: String
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, alignment: .center, spacing: 5) {
                        ForEach(Array(photos), id: \.id) { model in
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
            
        }
        .id(finishedID)
        .transition(.scale.animation(.easeInOut))
    }
}
