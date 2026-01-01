//
//  VideoCompressor.swift
//  CleanerApp
//
//  Created by iMac on 26/12/25.
//


import Foundation
import Photos
import AVFoundation
import Combine

// MARK: - VideoCompressor
final class VideoCompressor: ObservableObject {
    
    static let shared = VideoCompressor()
    private init() {}
    
    @Published private(set) var progressList: [VideoCompressionProgress] = []
    private var progressTimers: [String: Timer] = [:]
    
    func estimatedSizeRange(
        mediaItem: MediaItem,
        quality: VideoCompressionQuality
    ) -> String {
        
        let estimated = estimateCompressedSize(
            mediaItem: mediaItem,
            quality: quality
        )
        
        let minMB = Double(estimated) * 0.85 / (1024 * 1024)
        let maxMB = Double(estimated) * 1.15 / (1024 * 1024)
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        
        let minText = formatter.string(from: NSNumber(value: minMB)) ?? "0"
        let maxText = formatter.string(from: NSNumber(value: maxMB)) ?? "0"
        
        return "Estimated size: ~\(minText)–\(maxText) MB"
    }
    
    func estimateCompressedSize(
        mediaItem: MediaItem,
        quality: VideoCompressionQuality
    ) -> Int64 {
        guard mediaItem.asset.mediaType == .video else {
            return mediaItem.fileSize
        }
        
        let duration = max(mediaItem.asset.duration, 1) // seconds
        let bitrateMbps = quality.estimatedBitrateMbps
        
        var estimatedBytes =
        (duration * bitrateMbps * 1_000_000) / 8
        
        let width = Double(mediaItem.asset.pixelWidth)
        let height = Double(mediaItem.asset.pixelHeight)
        let pixelCount = width * height
        
        let referencePixels = 1920.0 * 1080.0
        let resolutionRatio = pixelCount / referencePixels
        
        if resolutionRatio >= 4 {            // 4K and above
            estimatedBytes *= 0.65
        } else if resolutionRatio >= 2 {     // 1440p
            estimatedBytes *= 0.8
        } else if resolutionRatio < 1 {      // <1080p
            estimatedBytes *= 1.1
        }
        
        switch duration {
        case 0..<30:
            estimatedBytes *= 1.15
        case 30..<180:
            break
        default:
            estimatedBytes *= 0.9
        }
        
        return Int64(estimatedBytes)
    }
    
    func compressVideo(
        mediaItem: MediaItem,
        quality: VideoCompressionQuality
    ) async throws -> (url: URL, asset: PHAsset) {
        
        let phAsset = mediaItem.asset
        let assetId = phAsset.localIdentifier
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        
        await MainActor.run {
            self.insertOrResetProgress(assetId)
        }
        
        let avAsset: AVURLAsset = try await withCheckedThrowingContinuation { cont in
            PHImageManager.default().requestAVAsset(forVideo: phAsset, options: options) { asset, _, info in
                if let error = info?[PHImageErrorKey] as? Error {
                    cont.resume(throwing: error)
                    return
                }
                
                if let cancelled = info?[PHImageCancelledKey] as? Bool, cancelled {
                    cont.resume(throwing: CancellationError())
                    return
                }
                
                guard let urlAsset = asset as? AVURLAsset else {
                    cont.resume(throwing: NSError(domain: "VideoCompressor", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load AVAsset"]))
                    return
                }
                
                cont.resume(returning: urlAsset)
            }
        }
        
        guard let export = AVAssetExportSession(asset: avAsset, presetName: quality.exportPreset) else {
            throw NSError(domain: "VideoCompressor", code: -2)
        }
        
        let baseName = mediaItem.filename.replacingOccurrences(of: ".mp4", with: "")
        let outputURL = makeOutputURL(for: assetId,fileName: "\(baseName)_compressed_\(Utility.fileNameTimeStamp()).mp4")
        
        export.outputURL = outputURL
        export.outputFileType = .mp4
        export.shouldOptimizeForNetworkUse = true
        
        startProgressTracking(export: export, assetId: assetId)
        
        await export.export()
        
        stopProgressTracking(assetId: assetId)
        
        await MainActor.run {
            self.markCompleted(assetId)
        }
        
        guard export.status == .completed else {
            throw export.error ?? NSError(domain: "VideoCompressor", code: -3)
        }
        
        var createdAssetId: String?
        
        try await PHPhotoLibrary.shared().performChanges {
            let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
            request?.creationDate = phAsset.creationDate
            request?.isFavorite = phAsset.isFavorite
            
            createdAssetId = request?.placeholderForCreatedAsset?.localIdentifier
        }
        
        guard let newId = createdAssetId,
              let newAsset = PHAsset.fetchAssets(withLocalIdentifiers: [newId], options: nil).firstObject
        else {
            throw NSError(
                domain: "VideoCompressor",
                code: -4,
                userInfo: [NSLocalizedDescriptionKey: "Failed to fetch created PHAsset"]
            )
        }
        
        try? FileManager.default.removeItem(at: outputURL)
        
        return (outputURL, newAsset)
    }
    
    private func makeOutputURL(for assetId: String, fileName: String) -> URL {
        
        let folder = FileManager.default.temporaryDirectory
            .appendingPathComponent("compressed_videos", isDirectory: true)
        
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
        } catch {
            fatalError("Failed to create folder for compression: \(error)")
        }
        
        let fileURL = folder.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                fatalError("Failed to remove existing file: \(error)")
            }
        }
        
        return fileURL
    }
    
    func insertOrResetProgress(_ assetId: String) {
        if let index = progressList.firstIndex(where: { $0.id == assetId }) {
            progressList[index].progress = 0
            progressList[index].isCompleted = false
        } else {
            progressList.append(VideoCompressionProgress(id: assetId, progress: 0, isCompleted: false))
        }
    }
    
    func markCompleted(_ assetId: String) {
        guard let index = progressList.firstIndex(where: { $0.id == assetId }) else { return }
        progressList[index].progress = 1
        progressList[index].isCompleted = true
    }
    
    func startProgressTracking(export: AVAssetExportSession, assetId: String) {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            
            let progress = Double(export.progress)
            print(export.progress)
            
            Task { @MainActor in
                if let index = self.progressList.firstIndex(where: { $0.id == assetId }) {
                    self.progressList[index].progress = progress
                }
            }
        }
        
        progressTimers[assetId] = timer
    }
    
    func stopProgressTracking(assetId: String) {
        progressTimers[assetId]?.invalidate()
        progressTimers.removeValue(forKey: assetId)
    }
}
