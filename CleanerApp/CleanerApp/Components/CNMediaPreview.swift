//
//  CNMediaPreview.swift
//  CleanerApp
//
//  Created by iMac on 05/12/25.
//

import SwiftUI
import PhotosUI
import AVKit
import SDWebImageSwiftUI
import SDWebImagePhotosPlugin

struct CNMediaPreview: View {
    let mediaItem: MediaItem
    @State private var image: UIImage?
    @State private var livePhoto: PHLivePhoto?
    @State private var player: AVPlayer?
    @State private var isLoading = false

    var body: some View {
        GeometryReader { proxy in
            Group {
                // PHOTO
                if mediaItem.type == .photos || mediaItem.type == .screenshots, let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipped()
                        .onDisappear {
                            self.image = nil
                        }
                }
                
                // VIDEO
                else if mediaItem.type == .screenRecordings || mediaItem.type == .videos || mediaItem.type == .largeVideos || mediaItem.type == .compressVideos, let player {
                    VideoPlayer(player: player)
                        .onAppear {
                            player.play()
                        }
                        .onDisappear {
                            self.player?.pause()
                            self.player = nil
                        }
                        .clipped()
                }
                
                // LIVE PHOTO
                else if mediaItem.type == .livePhotos, let livePhoto {
                    CNLivePhotoView(livePhoto: livePhoto)
                        .clipped()
                }
                
                else {
                    ProgressView()
                        .onAppear(perform: load)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
        }
    }
}

extension CNMediaPreview {
    
    func load() {
        guard !isLoading else { return }
        isLoading = true
        
        let asset = mediaItem.asset
        
        if mediaItem.type == .photos || mediaItem.type == .screenshots {
            Task {
                self.image = await PhotoService.shared.loadImage(asset: asset, isSynchronous: false, isHighQuality: true, targetSize: .zero)
            }
        }
        
        // VIDEO
        if mediaItem.type == .screenRecordings || mediaItem.type == .videos || mediaItem.type == .largeVideos || mediaItem.type == .compressVideos {
            PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { avAsset, _, _ in
                if let urlAsset = avAsset as? AVURLAsset {
                    DispatchQueue.main.async {
                        self.player = AVPlayer(url: urlAsset.url)
                    }
                }
            }
            return
        }
         
        // LIVE PHOTO
        if mediaItem.type == .livePhotos {
            let options = PHLivePhotoRequestOptions()
            options.isNetworkAccessAllowed = true
            
            PHImageManager.default().requestLivePhoto(
                for: asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit,
                options: options
            ) { livePhoto, _ in
                DispatchQueue.main.async {
                    self.livePhoto = livePhoto
                }
            }
            return
        }
    }
}
