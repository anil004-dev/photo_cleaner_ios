//
//  DuplicateMediaManager.swift
//  CleanerApp
//
//  Created by iMac on 16/12/25.
//

import Photos
import CryptoKit

// MARK: - Duplicate Media Manager
final class DuplicateMediaManager {

    static let shared = DuplicateMediaManager()
    private init() {}

    private let semaphore = AsyncSemaphore(value: 1)

    func findExactDuplicateGroups(
        in items: [MediaItem],
        chunkSize: Int = 40
    ) async -> [SimilarMedia] {

        let preGroups = Dictionary(grouping: items) {
            "\($0.asset.pixelWidth)x\($0.asset.pixelHeight)-\($0.fileSize)"
        }
        .values
        .filter { $0.count > 1 }

        var rawGroups: [[MediaItem]] = []

        await withTaskGroup(of: [[MediaItem]].self) { group in
            for pg in preGroups {
                group.addTask(priority: .utility) {
                    await self.semaphore.wait()
                    defer { Task { await self.semaphore.signal() } }
                    return await self.hashDuplicates(pg)
                }
            }

            for await g in group {
                rawGroups.append(contentsOf: g)
            }
        }

        return await convert(rawGroups)
    }

    // MARK: - Compute SHA256 with cache
    private func hashDuplicates(_ items: [MediaItem]) async -> [[MediaItem]] {
        var map: [String: [MediaItem]] = [:]

        for item in items {
            if Task.isCancelled { break }
            await Task.yield()

            if let cachedHash = await DuplicateHashCache.shared.get(item.assetId) {
                map[cachedHash, default: []].append(item)
                continue
            }

            // Compute hash if not cached
            guard let data = await loadData(asset: item.asset) else { continue }
            let hash = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()

            map[hash, default: []].append(item)
            await DuplicateHashCache.shared.set(item.assetId, value: hash)
        }

        return map.values.filter { $0.count > 1 }
    }

    // MARK: - Load full image data
    private func loadData(asset: PHAsset) async -> Data? {
        await withCheckedContinuation { cont in
            let opt = PHImageRequestOptions()
            opt.isSynchronous = false
            opt.isNetworkAccessAllowed = true
            opt.deliveryMode = .highQualityFormat

            PHImageManager.default()
                .requestImageDataAndOrientation(for: asset, options: opt) { data, _, _, _ in
                    cont.resume(returning: data)
                }
        }
    }

    // MARK: - Convert to SimilarMedia
    private func convert(_ raw: [[MediaItem]]) async -> [SimilarMedia] {
        raw.enumerated().map { idx, items in
            let best = items.first(where: { $0.isFavourite }) ??
                       items.max(by: { ($0.creationDate ?? .distantPast) < ($1.creationDate ?? .distantPast) }) ??
                       items[0]

            var sorted = items.filter { $0.id != best.id }
            sorted.insert(best, at: 0)

            return SimilarMedia(
                title: "Exact Duplicate \(idx + 1)",
                bestMediaAssetId: best.assetId,
                arrMediaItems: sorted
            )
        }
    }
}
