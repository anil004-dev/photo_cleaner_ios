//
//  LivePhotoStillExtractor.swift
//  CleanerApp
//
//  Created by iMac on 29/12/25.
//

import Photos
import AVFoundation
import UIKit

final class LivePhotoStillExtractor {

    static let shared = LivePhotoStillExtractor()
    private init() {}

    func extractPreviewImageURLs(
        from mediaItem: MediaItem
    ) async throws -> [URL] {

        guard mediaItem.asset.mediaSubtypes.contains(.photoLive) else {
            throw NSError(
                domain: "LivePhoto",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Not a Live Photo"]
            )
        }

        // 1️⃣ Find paired video resource
        let resources = PHAssetResource.assetResources(for: mediaItem.asset)
        guard let videoResource = resources.first(where: { $0.type == .pairedVideo }) else {
            throw NSError(
                domain: "LivePhoto",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Paired video not found"]
            )
        }

        // 2️⃣ Write paired video to temp file
        let tempVideoURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mov")

        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = true

        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            PHAssetResourceManager.default().writeData(
                for: videoResource,
                toFile: tempVideoURL,
                options: options
            ) { error in
                if let error {
                    cont.resume(throwing: error)
                } else {
                    cont.resume(returning: ())
                }
            }
        }

        // 3️⃣ Create AVAsset
        let avAsset = AVURLAsset(url: tempVideoURL)

        // 4️⃣ Load duration (iOS 16+ safe)
        let duration = try await avAsset.load(.duration).seconds

        let generator = AVAssetImageGenerator(asset: avAsset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero
        // ❗ No maximumSize → full resolution preserved

        let times: [CMTime] = [
            CMTime(seconds: duration * 0.1, preferredTimescale: 600),
            CMTime(seconds: duration * 0.5, preferredTimescale: 600),
            CMTime(seconds: duration * 0.9, preferredTimescale: 600)
        ]

        var imageURLs: [URL] = []

        // 5️⃣ Extract frames and write to temp image files
        for time in times {
            let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
            let image = UIImage(cgImage: cgImage)

            let imageURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("png")

            guard let data = image.pngData() else {
                continue
            }

            try data.write(to: imageURL, options: .atomic)
            imageURLs.append(imageURL)
        }

        // 6️⃣ Cleanup temp video
        try? FileManager.default.removeItem(at: tempVideoURL)

        return imageURLs
    }
}
