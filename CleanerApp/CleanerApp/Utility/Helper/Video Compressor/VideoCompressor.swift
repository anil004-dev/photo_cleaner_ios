//
//  VideoCompressor.swift
//  CleanerApp
//
//  Created by iMac on 26/12/25.
//


/*import Foundation
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
 */

import Foundation
import AVFoundation
import Photos

final class VideoCompressorManager {
    
    static let shared = VideoCompressorManager()
    private init() {}
    
    // MARK: - Estimate Video Size
    func estimateSize(
        media: MediaItem,
        quality: VideoCompressionQuality
    ) async -> VideoCompressionInfo {
        
        guard let url = await getVideoURL(from: media.asset) else {
            return emptyInfo(media, quality)
        }
        
        let asset = AVAsset(url: url)
        
        guard let dur = try? await asset.load(.duration) else {
            return emptyInfo(media, quality)
        }
        
        let duration = CMTimeGetSeconds(dur)
        guard duration > 0 else { return emptyInfo(media, quality) }
        
        let videoBitrate = Double(await getOriginalBitrate(asset: asset))
        let audioBitrate = await getAudioBitrate(asset: asset)
        
        let baseVideoBitrate = videoBitrate > 0
        ? videoBitrate
        : quality.targetBitrate * 1_000_000
        
        let compressionFactor: Double
        switch quality {
        case .low:    compressionFactor = 0.25
        case .medium: compressionFactor = 0.45
        case .high:   compressionFactor = 0.70
        }
        
        let targetVideoBitrate = baseVideoBitrate * compressionFactor
        let totalBitrate = targetVideoBitrate + audioBitrate
        
        let estimatedBytes = (totalBitrate * duration) / 8
        let estimatedSize = Int64(estimatedBytes)
        let finalEstimate = min(estimatedSize, media.fileSize)
        let savedSize = max(0, media.fileSize - finalEstimate)
        
        return VideoCompressionInfo(
            originalSize: media.fileSize,
            estimatedSize: finalEstimate,
            savedSize: savedSize,
            quality: quality
        )
    }
    
    // MARK: - Compress Video
    func compressVideo(
        media: MediaItem,
        quality: VideoCompressionQuality,
        progress: @escaping (Double) -> Void
    ) async throws -> URL {

        guard let sourceURL = await getVideoURL(from: media.asset) else {
            throw CompressionError.assetNotFound
        }

        let asset = AVAsset(url: sourceURL)
        let outputURL = makeOutputURL()

        // 1️⃣ Load all async info first
        let videoTrack = try await asset.loadTracks(withMediaType: .video).first
            ?? { throw CompressionError.readerFailed }()

        // Fix orientation
        let size = try await videoTrack.load(.naturalSize)
        let transform = try await videoTrack.load(.preferredTransform)

        let videoSize: CGSize
        if transform.a == 0 && abs(transform.b) == 1 && abs(transform.c) == 1 && transform.d == 0 {
            videoSize = CGSize(width: abs(size.height), height: abs(size.width))
        } else {
            videoSize = CGSize(width: abs(size.width), height: abs(size.height))
        }

        let durationSeconds = CMTimeGetSeconds(try await asset.load(.duration))

        let originalBitrate = Double(await getOriginalBitrate(asset: asset))

        let fps = await {
            let rate = try? await videoTrack.load(.nominalFrameRate)
            return (rate ?? 0) > 0 ? rate! : 30
        }()

        let desiredBitrate: Double = {
            switch quality {
            case .low: return 800_000
            case .medium: return 2_000_000
            case .high: return 4_000_000
            }
        }()

        // Never upscale
        let targetBitrate = min(originalBitrate, desiredBitrate)

        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: videoSize.width,
            AVVideoHeightKey: videoSize.height,
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: Int(targetBitrate),
                AVVideoExpectedSourceFrameRateKey: Int(fps),
                AVVideoMaxKeyFrameIntervalKey: Int(fps * 2),
                AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
            ]
        ]

        // 2️⃣ Call synchronous transcode
        return try await withCheckedThrowingContinuation { continuation in
            transcode(
                asset: asset,
                videoTrack: videoTrack,
                durationSeconds: durationSeconds,
                outputURL: outputURL,
                videoSettings: videoSettings,
                progress: progress
            ) { result in
                switch result {
                case .success(let url):
                    continuation.resume(returning: url)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: - Synchronous transcode
    func transcode(
        asset: AVAsset,
        videoTrack: AVAssetTrack,
        durationSeconds: Double,
        outputURL: URL,
        videoSettings: [String: Any],
        progress: @escaping (Double) -> Void,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let reader = try AVAssetReader(asset: asset)
                let writer = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)

                let videoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: [
                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
                ])
                let videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
                videoInput.expectsMediaDataInRealTime = false

                reader.add(videoOutput)
                writer.add(videoInput)

                writer.startWriting()
                reader.startReading()
                writer.startSession(atSourceTime: .zero)

                // Safe writing loop
                let queue = DispatchQueue(label: "video.compress.queue")
                queue.async {
                    videoInput.requestMediaDataWhenReady(on: queue) {
                        while videoInput.isReadyForMoreMediaData {
                            if reader.status != .reading {
                                videoInput.markAsFinished()
                                writer.finishWriting {
                                    DispatchQueue.main.async { completion(.success(outputURL)) }
                                }
                                return
                            }

                            guard let sampleBuffer = videoOutput.copyNextSampleBuffer() else {
                                videoInput.markAsFinished()
                                writer.finishWriting {
                                    DispatchQueue.main.async { completion(.success(outputURL)) }
                                }
                                return
                            }

                            if CMSampleBufferIsValid(sampleBuffer) {
                                _ = videoInput.append(sampleBuffer)
                            }
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}

// MARK: - Helpers & Extensions
extension VideoCompressorManager {
    
    private func emptyInfo(_ media: MediaItem, _ quality: VideoCompressionQuality) -> VideoCompressionInfo {
        VideoCompressionInfo(
            originalSize: media.fileSize,
            estimatedSize: 0,
            savedSize: 0,
            quality: quality
        )
    }
    
    func getOriginalBitrate(asset: AVAsset) async -> Float {
        guard let track = try? await asset.loadTracks(withMediaType: .video).first,
              let estimatedDataRate = try? await track.load(.estimatedDataRate)
        else { return 0 }
        return estimatedDataRate
    }
    
    func getAudioBitrate(asset: AVAsset) async -> Double {
        guard let track = try? await asset.loadTracks(withMediaType: .audio).first,
              let estimatedDataRate = try? await track.load(.estimatedDataRate)
        else { return 128_000 }
        return Double(estimatedDataRate > 0 ? estimatedDataRate : 128_000)
    }
    
    func getVideoURL(from asset: PHAsset) async -> URL? {
        await withCheckedContinuation { continuation in
            let options = PHVideoRequestOptions()
            options.version = .original
            options.deliveryMode = .highQualityFormat
            
            PHImageManager.default()
                .requestAVAsset(forVideo: asset, options: options) { avAsset, _, _ in
                    if let urlAsset = avAsset as? AVURLAsset {
                        continuation.resume(returning: urlAsset.url)
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
        }
    }
    
    private func makeOutputURL() -> URL {
        let dir = FileManager.default.temporaryDirectory
        let name = UUID().uuidString + ".mp4"
        return dir.appendingPathComponent(name)
    }
    
    enum CompressionError: Error {
        case assetNotFound
        case exportFailed
        case readerFailed
        case writerFailed
    }
}
