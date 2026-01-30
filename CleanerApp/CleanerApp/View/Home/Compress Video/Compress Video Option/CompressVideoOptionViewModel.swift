//
//  CompressVideoOptionViewModel.swift
//  CleanerApp
//
//  Created by iMac on 30/01/26.
//

import Combine

class CompressVideoOptionViewModel: ObservableObject {
    var mediaItem: MediaItem
    @Published var compressInfo: VideoCompressionInfo
    
    init(mediaItem: MediaItem, compressInfo: VideoCompressionInfo) {
        self.mediaItem = mediaItem
        self._compressInfo = Published(initialValue: compressInfo)
    }
    
    func selectQuality(quality: VideoCompressionQuality) {
        Task {
            compressInfo = await VideoCompressorManager.shared.estimateSize(media: mediaItem, quality: quality)
        }
    }
    
    func btnCompressVideoAction() {
        CNLoader.show()
        
        Task {
            do {
                let compressedURL = try await VideoCompressorManager.shared.compressVideo(
                    media: mediaItem,
                    quality: compressInfo.quality
                ) { progress in
                    // This closure gets called frequently with 0.0 -> 1.0
                    print("Compression progress: \(Int(progress * 100))%")
                }

                try await MediaDatabase.shared.saveVideoToGallery(from: compressedURL)
                await MainActor.run {
                    CNLoader.dismiss()
                    CNAlertManager.shared.showAlert(title: "Success", message: "Video saved to gallery succesfuly")
                }
            } catch {
                await MainActor.run {
                    CNLoader.dismiss()
                    CNAlertManager.shared.showAlert(title: "Error occured", message: "Failed to compress a video, please try again later.")
                }
            }
        }
    }
}
