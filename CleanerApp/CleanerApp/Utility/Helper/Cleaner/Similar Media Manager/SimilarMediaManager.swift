//
//  SimilarMediaManager.swift
//  CleanerApp
//
//  Created by ChatGPT on 08/12/25.
//

import UIKit
import Photos

final class SimilarMediaManager {
    static let shared = SimilarMediaManager()
    private init() {}

    /// Main API
    func findSimilarMediaGroups(
        in items: [MediaItem],
        threshold: Int = 12,
        chunkSize: Int = 80
    ) async -> [SimilarMedia] {

        let chunks = items.chunked(into: chunkSize)
        var allGroups: [[MediaItem]] = []

        // Limit concurrency for hashing to reduce lag
        let semaphore = AsyncSemaphore(value: 2) // allow 2 chunks at a time

        await withTaskGroup(of: [[MediaItem]].self) { group in
            for chunk in chunks {
                group.addTask(priority: .userInitiated) {
                    await semaphore.wait()
                    let data = await self.computeHashes(for: chunk)
                    let groups = await self.groupSimilar(data, threshold: threshold)
                    await semaphore.signal()
                    return groups
                }
            }

            for await groups in group {
                allGroups.append(contentsOf: groups)
            }
        }

        return await convertGroups(allGroups)
    }

    private func computeHashes(for items: [MediaItem]) async -> [(MediaItem, [Bool])] {
        var result: [(MediaItem, [Bool])] = []
        result.reserveCapacity(items.count)

        for item in items {
            if let img = await PhotoService.shared.loadImage(
                asset: item.asset,
                isSynchronous: false,
                isHighQuality: false,
                targetSize: CGSize(width: 32, height: 32)
            ) {
                let hash = combinedHash(image: img)
                result.append((item, hash))
            }
        }
        return result
    }

    private func combinedHash(image: UIImage) -> [Bool] {
        let size = CGSize(width: 8, height: 8)
        guard let resized = image.resize(to: size),
              let cg = resized.cgImage else { return [] }

        var pixels = [UInt8](repeating: 0, count: 64)
        let cs = CGColorSpaceCreateDeviceGray()
        let ctx = CGContext(
            data: &pixels,
            width: 8,
            height: 8,
            bitsPerComponent: 8,
            bytesPerRow: 8,
            space: cs,
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        )!
        ctx.draw(cg, in: CGRect(origin: .zero, size: size))

        let sum = pixels.map(Int.init).reduce(0, +)
        let avg = sum / pixels.count
        let aHash = pixels.map { $0 > avg }

        var dHash: [Bool] = []
        for y in 0..<8 { for x in 0..<7 {
            dHash.append(pixels[y*8+x] > pixels[y*8+x+1])
        }}
        return aHash + dHash
    }

    private func hammingDistance(_ a: [Bool], _ b: [Bool]) -> Int {
        zip(a, b).reduce(0) { $0 + ($1.0 != $1.1 ? 1 : 0) }
    }

    private func groupSimilar(_ data: [(MediaItem, [Bool])], threshold: Int) -> [[MediaItem]] {
        var groups: [[MediaItem]] = []
        var used = Set<Int>()

        for i in 0..<data.count {
            if used.contains(i) { continue }
            var group = [data[i].0]
            used.insert(i)

            for j in (i+1)..<data.count {
                if used.contains(j) { continue }
                if hammingDistance(data[i].1, data[j].1) <= threshold {
                    group.append(data[j].0)
                    used.insert(j)
                }
            }

            if group.count > 1 { groups.append(group) }
        }

        return groups
    }

    private func convertGroups(_ raw: [[MediaItem]]) async -> [SimilarMedia] {
        var finalGroups: [SimilarMedia] = []

        await withTaskGroup(of: SimilarMedia.self) { group in
            for (idx, items) in raw.enumerated() {
                group.addTask(priority: .userInitiated) {
                    await self.createSimilarMedia(idx: idx, items: items)
                }
            }

            for await similar in group {
                // Incrementally update UI
                Task { @MainActor in
                    finalGroups.append(similar)
                }
            }
        }

        return finalGroups.sortedByNewest()
    }

    private func createSimilarMedia(idx: Int, items: [MediaItem]) async -> SimilarMedia {
        if let favoriteItem = items.first(where: { $0.isFavourite }) {
            var sortedGroup = items.filter { $0.id != favoriteItem.id }
            sortedGroup.insert(favoriteItem, at: 0)
            return SimilarMedia(
                title: "Similar \(idx + 1)",
                bestMediaAssetId: favoriteItem.assetId,
                arrMediaItems: sortedGroup
            )
        }

        // Limit concurrency for score computation
        let scoreSemaphore = AsyncSemaphore(value: 2)
        let scoredItems = await withTaskGroup(of: (MediaItem, Int).self) { scoresGroup -> [(MediaItem, Int)] in
            var result: [(MediaItem, Int)] = []
            for item in items {
                scoresGroup.addTask {
                    await scoreSemaphore.wait()
                    let scoreValue = await item.score()
                    await scoreSemaphore.signal()
                    return (item, scoreValue)
                }
            }
            for await scored in scoresGroup { result.append(scored) }
            return result
        }

        let bestItem = scoredItems.max { $0.1 < $1.1 }?.0 ?? items[0]
        var sortedGroup = items.filter { $0.id != bestItem.id }
        sortedGroup.insert(bestItem, at: 0)

        return SimilarMedia(
            title: "Similar \(idx + 1)",
            bestMediaAssetId: bestItem.assetId,
            arrMediaItems: sortedGroup
        )
    }
}
