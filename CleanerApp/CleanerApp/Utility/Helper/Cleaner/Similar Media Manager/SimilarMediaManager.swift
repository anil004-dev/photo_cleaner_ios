//
//  SimilarMediaManager.swift
//  CleanerApp
//
//  Created by ChatGPT on 08/12/25.
//

/*import UIKit
import Photos

final class SimilarMediaManager {
    static let shared = SimilarMediaManager()
    private init() {}

    // MARK: - Hash type (FAST)
    private struct ImageHash {
        let a: UInt64   // aHash (64 bits)
        let d: UInt64   // dHash (56 bits used)
    }

    // MARK: - Main API
    func findSimilarMediaGroups(
        in items: [MediaItem],
        threshold: Int = 18, //12
        chunkSize: Int = 80
    ) async -> [SimilarMedia] {

        let chunks = items.chunked(into: chunkSize)
        var allGroups: [[MediaItem]] = []

        let semaphore = AsyncSemaphore(value: 2)

        await withTaskGroup(of: [[MediaItem]].self) { group in
            for chunk in chunks {
                group.addTask(priority: .userInitiated) {
                    await semaphore.wait()
                    defer { Task { await semaphore.signal() } }

                    let data = await self.computeHashes(for: chunk)
                    return await self.groupSimilar(data, threshold: threshold)
                }
            }

            for await groups in group {
                allGroups.append(contentsOf: groups)
            }
        }

        return await convertGroups(allGroups)
    }

    // MARK: - Hash computation
    private func computeHashes(for items: [MediaItem]) async -> [(MediaItem, ImageHash)] {
        var result: [(MediaItem, ImageHash)] = []
        result.reserveCapacity(items.count)

        for item in items {
            if let img = await PhotoService.shared.loadImage(
                asset: item.asset,
                isSynchronous: false,
                isHighQuality: false,
                targetSize: CGSize(width: 32, height: 32)
            ) {
                result.append((item, combinedHash(image: img)))
            }
        }
        return result
    }

    private func combinedHash(image: UIImage) -> ImageHash {
        let size = CGSize(width: 8, height: 8)
        guard let resized = image.resize(to: size),
              let cg = resized.cgImage else {
            return ImageHash(a: 0, d: 0)
        }

        var pixels = [UInt8](repeating: 0, count: 64)
        let ctx = CGContext(
            data: &pixels,
            width: 8,
            height: 8,
            bitsPerComponent: 8,
            bytesPerRow: 8,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        )!
        ctx.draw(cg, in: CGRect(origin: .zero, size: size))

        let sum = pixels.reduce(0) { $0 + Int($1) }
        let avg = sum / pixels.count

        var aHash: UInt64 = 0
        for i in 0..<64 {
            if pixels[i] > avg {
                aHash |= (1 << UInt64(i))
            }
        }

        var dHash: UInt64 = 0
        var bit: UInt64 = 0
        for y in 0..<8 {
            for x in 0..<7 {
                if pixels[y * 8 + x] > pixels[y * 8 + x + 1] {
                    dHash |= (1 << bit)
                }
                bit += 1
            }
        }

        return ImageHash(a: aHash, d: dHash)
    }

    // MARK: - Fast Hamming
    @inline(__always)
    private func hamming(_ x: UInt64, _ y: UInt64) -> Int {
        (x ^ y).nonzeroBitCount
    }

    // MARK: - Similarity grouping (FIXED)
    private func groupSimilar(
        _ data: [(MediaItem, ImageHash)],
        threshold: Int
    ) -> [[MediaItem]] {

        var groups: [[MediaItem]] = []
        var used = Array(repeating: false, count: data.count)

        for i in 0..<data.count {
            if used[i] { continue }

            var group = [data[i].0]
            used[i] = true

            for j in (i + 1)..<data.count {
                if used[j] { continue }

                // Early exit pruning
                let dist =
                    hamming(data[i].1.a, data[j].1.a) +
                    hamming(data[i].1.d, data[j].1.d)

                if dist <= threshold {
                    group.append(data[j].0)
                    used[j] = true
                }
            }

            if group.count > 1 {
                groups.append(group)
            }
        }

        return groups
    }

    // MARK: - Convert groups
    private func convertGroups(_ raw: [[MediaItem]]) async -> [SimilarMedia] {
        var temp: [SimilarMedia] = []
        temp.reserveCapacity(raw.count)

        await withTaskGroup(of: SimilarMedia.self) { group in
            for (idx, items) in raw.enumerated() {
                group.addTask(priority: .utility) {
                    await self.createSimilarMedia(idx: idx, items: items)
                }
            }

            for await similar in group {
                temp.append(similar)
            }
        }

        return temp.sortedByNewest()
    }

    // MARK: - Best media selection
    private func createSimilarMedia(idx: Int, items: [MediaItem]) async -> SimilarMedia {

        if let favoriteItem = items.first(where: { $0.isFavourite }) {
            var sorted = items.filter { $0.id != favoriteItem.id }
            sorted.insert(favoriteItem, at: 0)
            return SimilarMedia(
                title: "Similar \(idx + 1)",
                bestMediaAssetId: favoriteItem.assetId,
                arrMediaItems: sorted
            )
        }

        let scoreSemaphore = AsyncSemaphore(value: 2)
        let scored = await withTaskGroup(of: (MediaItem, Int).self) { group -> [(MediaItem, Int)] in
            var result: [(MediaItem, Int)] = []

            for item in items {
                group.addTask(priority: .utility) {
                    await scoreSemaphore.wait()
                    defer { Task { await scoreSemaphore.signal() } }
                    return (item, await item.score())
                }
            }

            for await s in group { result.append(s) }
            return result
        }

        let best = scored.max { $0.1 < $1.1 }?.0
        var sorted = items.filter { $0.id != best?.id }
        if let best { sorted.insert(best, at: 0) }

        return SimilarMedia(
            title: "Similar \(idx + 1)",
            bestMediaAssetId: best?.assetId,
            arrMediaItems: sorted
        )
    }
}
*/

import UIKit
import Photos
import Foundation


// MARK: - Similar Media Manager
final class SimilarMediaManager {
    static let shared = SimilarMediaManager()
    private init() {}

    private struct ImageHash {
        let a: UInt64
        let d: UInt64
    }

    // MARK: - Main API
    func findSimilarMediaGroups(
        in items: [MediaItem],
        threshold: Int = 18,
        chunkSize: Int = 80
    ) async -> [SimilarMedia] {

        let chunks = items.chunked(into: chunkSize)
        var allGroups: [[MediaItem]] = []
        let semaphore = AsyncSemaphore(value: 2)

        await withTaskGroup(of: [[MediaItem]].self) { group in
            for chunk in chunks {
                group.addTask(priority: .userInitiated) {
                    await semaphore.wait()
                    defer { Task { await semaphore.signal() } }

                    let data = await self.computeHashes(for: chunk)
                    return await self.groupSimilar(data, threshold: threshold)
                }
            }

            for await groups in group {
                allGroups.append(contentsOf: groups)
            }
        }

        return await convertGroups(allGroups)
    }

    // MARK: - Compute hashes (with cache)
    private func computeHashes(for items: [MediaItem]) async -> [(MediaItem, ImageHash)] {
        var result: [(MediaItem, ImageHash)] = []
        result.reserveCapacity(items.count)

        for item in items {
            if let cached = await HashCache.shared.get(item.assetId) {
                result.append((item, ImageHash(a: cached.0, d: cached.1)))
                continue
            }

            if let img = await PhotoService.shared.loadImage(
                asset: item.asset,
                isSynchronous: false,
                isHighQuality: false,
                targetSize: CGSize(width: 32, height: 32)
            ) {
                let hash = combinedHash(image: img)
                result.append((item, hash))
                await HashCache.shared.set(item.assetId, a: hash.a, d: hash.d)
            }
        }

        return result
    }

    private func combinedHash(image: UIImage) -> ImageHash {
        let size = CGSize(width: 8, height: 8)
        guard let resized = image.resize(to: size),
              let cg = resized.cgImage else { return ImageHash(a: 0, d: 0) }

        var pixels = [UInt8](repeating: 0, count: 64)
        let ctx = CGContext(
            data: &pixels,
            width: 8, height: 8, bitsPerComponent: 8,
            bytesPerRow: 8, space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        )!
        ctx.draw(cg, in: CGRect(origin: .zero, size: size))

        let avg = pixels.reduce(0) { $0 + Int($1) } / pixels.count

        var aHash: UInt64 = 0
        for i in 0..<64 { if pixels[i] > avg { aHash |= (1 << UInt64(i)) } }

        var dHash: UInt64 = 0
        var bit: UInt64 = 0
        for y in 0..<8 { for x in 0..<7 {
            if pixels[y * 8 + x] > pixels[y * 8 + x + 1] { dHash |= (1 << bit) }
            bit += 1
        }}

        return ImageHash(a: aHash, d: dHash)
    }

    @inline(__always)
    private func hamming(_ x: UInt64, _ y: UInt64) -> Int { (x ^ y).nonzeroBitCount }

    // MARK: - Grouping
    private func groupSimilar(_ data: [(MediaItem, ImageHash)], threshold: Int) -> [[MediaItem]] {
        var groups: [[MediaItem]] = []
        var used = Array(repeating: false, count: data.count)

        for i in 0..<data.count {
            if used[i] { continue }
            var group = [data[i].0]; used[i] = true
            for j in (i + 1)..<data.count {
                if used[j] { continue }
                let dist = hamming(data[i].1.a, data[j].1.a) + hamming(data[i].1.d, data[j].1.d)
                if dist <= threshold { group.append(data[j].0); used[j] = true }
            }
            if group.count > 1 { groups.append(group) }
        }

        return groups
    }

    // MARK: - Convert to SimilarMedia
    private func convertGroups(_ raw: [[MediaItem]]) async -> [SimilarMedia] {
        var temp: [SimilarMedia] = []
        temp.reserveCapacity(raw.count)

        await withTaskGroup(of: SimilarMedia.self) { group in
            for (idx, items) in raw.enumerated() {
                group.addTask(priority: .utility) { await self.createSimilarMedia(idx: idx, items: items) }
            }

            for await similar in group { temp.append(similar) }
        }

        return temp.sortedByNewest()
    }

    // MARK: - Best media selection (with score cache)
    private func createSimilarMedia(idx: Int, items: [MediaItem]) async -> SimilarMedia {
        if let favoriteItem = items.first(where: { $0.isFavourite }) {
            var sorted = items.filter { $0.id != favoriteItem.id }
            sorted.insert(favoriteItem, at: 0)
            return SimilarMedia(title: "Similar \(idx + 1)", bestMediaAssetId: favoriteItem.assetId, arrMediaItems: sorted)
        }

        let scoreSemaphore = AsyncSemaphore(value: 2)
        let scored = await withTaskGroup(of: (MediaItem, Int).self) { group -> [(MediaItem, Int)] in
            var result: [(MediaItem, Int)] = []
            for item in items {
                group.addTask(priority: .utility) {
                    await scoreSemaphore.wait()
                    defer { Task { await scoreSemaphore.signal() } }

                    // ✅ Check score cache first
                    if let cachedScore = await ScoreCache.shared.get(item.assetId) {
                        return (item, cachedScore)
                    }

                    let s = await item.score()
                    await ScoreCache.shared.set(item.assetId, value: s)
                    return (item, s)
                }
            }
            for await s in group { result.append(s) }
            return result
        }

        let best = scored.max { $0.1 < $1.1 }?.0
        var sorted = items.filter { $0.id != best?.id }
        if let best { sorted.insert(best, at: 0) }

        return SimilarMedia(title: "Similar \(idx + 1)", bestMediaAssetId: best?.assetId, arrMediaItems: sorted)
    }
}

