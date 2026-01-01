//
//  CNLivePhotoImagePreviewView.swift
//  CleanerApp
//
//  Created by iMac on 29/12/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct CNLivePhotoImagePreviewView: View {
    
    let arrImageURLs: [URL]
    @State var selectedImageURL: URL
    var onConvertAction: ((URL) -> Void)
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading, spacing: 0) {
                    imagePreviewSection
                }
            }
            .navigationTitle("Image Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onConvertAction(selectedImageURL)
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
    }
    
    private var imagePreviewSection: some View {
        ScrollView(.vertical) {
            LazyVStack(alignment: .leading, spacing: 20) {
                ForEach(arrImageURLs, id: \.self) { url in
                    let width = UIScreen.main.bounds.width - 20
                    let height = 300.0
                    let thumbnailSize = CGSize(width: width, height: height)
                    
                    ZStack {
                        WebImage(
                            url: url,
                            context: [
                                .imageThumbnailPixelSize: thumbnailSize,
                                .imageScaleFactor : UIScreen.main.scale
                            ]
                        )
                        .resizable()
                        .cancelOnDisappear(true)
                        .aspectRatio(contentMode: .fit)
                        .scaledToFit()
                        .frame(width: thumbnailSize.width, height: thumbnailSize.height)
                        .clipped()
                        .cornerRadius(10)
                        
                        VStack(alignment: .trailing, spacing: 0) {
                            HStack(alignment: .top, spacing: 0) {
                                Spacer()
                                Image(systemName: url == selectedImageURL ? "checkmark.square.fill" : "square")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(url == selectedImageURL ? .blue : .white)
                                    .frame(width: 20, height: 20)
                                    .contentShape(Rectangle())
                                    .zIndex(1)
                                    .allowsHitTesting(true)
                                    .padding(15)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedImageURL = url
                            }
                            
                            Spacer()
                        }
                    }
                    .onTapGesture {
                        selectedImageURL = url
                    }
                }
            }
        }
    }
}
