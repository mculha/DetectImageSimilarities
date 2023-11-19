//
//  PermissionView.swift
//  DetectImageSimilarities
//
//  Created by Melih Çulha on 19.11.2023.
//

import SwiftUI

struct PermissionView: View {
    @Environment(\.openURL) var openURL
    
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
                openURL(URL(string: UIApplication.openSettingsURLString)!)
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


#Preview {
    PermissionView()
}
