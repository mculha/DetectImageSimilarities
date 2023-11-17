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
            if viewModel.state == .permissionRequired {
                PermissionView()
            } else {
                VStack {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: Self.itemSpacing) {
                            ForEach(Array(viewModel.photos.keys), id: \.self) { key in
                                Image(uiImage: viewModel.photos[key]!.thumbnail)
                                    .frame(width: Self.itemSize.width, height: Self.itemSize.height)
                                    .clipped()
                                    .cornerRadius(Self.itemCornerRadius)
                                
                            }
                        }
                    }
                }
                .task {
                    await viewModel.requestPhotoAccess()
                }
                .padding()
                .navigationTitle("Photos")
            }
        }
    }
}

#Preview {
    PhotoCollectionView()
}


struct PermissionView: View {
    var body: some View {
        VStack {
            Image(.photosNeedPermission)
                .resizable()
                .scaledToFit()
            
            VStack(spacing: 15) {
                Text("Unlock Your Image Universe")
                    .font(.system(size: 18, weight: .bold))
                
                Text("Seamlessly compare and identify identical images within your gallery to organize and cherish your memories. Please grant gallery permission to unleash the full potential of this visual journey and witness the magic of finding similarities among your cherished snapshots.")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                
            }
            .padding(.horizontal, 25)
            
            Spacer()
            
            Button {
                // todo - Build Here
            } label: {
                Text("Grant Access")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(.photoGrandAccessBG)
                    .foregroundStyle(.photoGrandAccessText)
                    .clipShape(Capsule())
                    .padding(.horizontal, 25)
                    
            }
            
            Spacer()

        }
    }
}
