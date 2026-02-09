//
//  MediaType.swift
//  CleanerApp
//
//  Created by iMac on 15/12/25.
//

import Combine
import Foundation
import Photos
import Vision
import UIKit

// MARK: - Scan State
enum MediaScanState {
    case idle, scanning, completed
}

// MARK: - Media Types
enum MediaType: String, CaseIterable, Identifiable {
    case photos, screenshots, livePhotos, videos, screenRecordings, largeVideos, compressVideos
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .photos:
            return "Photos"
        case .screenshots:
            return "Screenshots"
        case .livePhotos:
            return "Live Photos"
        case .videos:
            return "Videos"
        case .screenRecordings:
            return "Screen Recordings"
        case .largeVideos:
            return "Large Videos"
        case .compressVideos:
            return "Compress Videos"
        }
    }
    
    var subType: String {
        switch self {
        case .photos:
            return "Photos"
        case .screenshots:
            return "Screenshots"
        case .livePhotos:
            return "Live Photos"
        case .videos:
            return "Videos"
        case .screenRecordings:
            return "Screen Recordings"
        case .largeVideos:
            return "Videos"
        case .compressVideos:
            return "Videos"
        }
    }
}

enum MediaItemSortType: String, CaseIterable {
    case name = "Name"
    case size = "Size"
    case date = "Date"
}

// MARK: - Category Model
final class MediaCategoryModel: ObservableObject, Identifiable, Equatable {
    let id = UUID()
    let type: MediaType
    
    var subType: String {
        return type.subType
    }
    
    @Published var items: [MediaItem] = []
    @Published var isScanning: Bool = true
    
    var title: String { type.title }
    var count: Int { items.count }
    var totalSize: Int64 { items.reduce(0) { $0 + $1.fileSize } }
    var formattedSize: String {
        Utility.formattedSize(byte: totalSize)
    }
    
    init(type: MediaType) {
        self.type = type
    }
    
    func setItems(arrItems: [MediaItem]) {
        items.append(contentsOf: arrItems)
        isScanning = false
        calculateSize()
    }
    
    func calculateSize() {
        guard !items.isEmpty else { return }

        DispatchQueue.global(qos: .background).async {
            for item in self.items.filter({ $0.fileSize == 0 }) {
                let id = item.id
                let size = item.asset.fileSizeSync()
                
                DispatchQueue.main.async {
                    if let index = self.items.firstIndex(where: { $0.id == id }) {
                        let item = self.items[index]
                        item.fileSize = size
                        self.items[index] = item
                    }
                }
            }
        }
    }
    
    static func == (lhs: MediaCategoryModel, rhs: MediaCategoryModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Media Item
class MediaItem: ObservableObject, Identifiable, Hashable {
    let id = UUID()
    let asset: PHAsset
    let type: MediaType
    @Published var fileSize: Int64
    let assetId: String
    var filename: String
    let creationDate: Date?
    let isFavourite: Bool
    let mediaTypeRaw: Int
    let mediaSubtypesRaw: UInt
    var thumbnailURL: URL?
    
    @Published var compressionInfo: VideoCompressionInfo?
    
    var formattedDate: String? {
        return creationDate?.formatted(.dateTime.day().month(.abbreviated))
    }
    
    init(asset: PHAsset, type: MediaType, fileSize: Int64, assetId: String, filename: String, creationDate: Date?, isFavourite: Bool, mediaTypeRaw: Int, mediaSubtypesRaw: UInt, thumbnailURL: URL? = nil) {
        self.asset = asset
        self.type = type
        self.fileSize = fileSize
        self.assetId = assetId
        self.filename = filename
        self.creationDate = creationDate
        self.isFavourite = isFavourite
        self.mediaTypeRaw = mediaTypeRaw
        self.mediaSubtypesRaw = mediaSubtypesRaw
        self.thumbnailURL = thumbnailURL
    }
    
    static func == (lhs: MediaItem, rhs: MediaItem) -> Bool {
        lhs.assetId == rhs.assetId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(assetId)
    }
}

extension MediaItem {
    
    private static var scoreCache: [String: Int] = [:] // assetId -> score
    
    /// Compute overall score asynchronously (memory-friendly)
    func score() async -> Int {
        // 1️⃣ Favorite always wins instantly
        if isFavourite {
            return 10_000
        }
        
        // 2️⃣ Check persistent cache first
        if let cached = await ScoreCache.shared.get(assetId) {
            return cached
        }
        
        // 3️⃣ Compute score (slow once)
        var score = 0
        
        if let image = await PhotoService.shared.loadImage(asset: asset, isSynchronous: false, isHighQuality: false, targetSize: CGSize(width: 128, height: 128)) {
            score += await computeImageScore(image: image)
        }
        
        // optional tiny bonus for original file size
        score += min(5, Int(fileSize / 1_000_000))
        
        // 4️⃣ Save to persistent cache
        await ScoreCache.shared.set(assetId, value: score)
        
        return score
    }

    func computeImageScore(image: UIImage) async -> Int {
        var score = 0
        
        // Physical quality: heavy weight
        score += computeSharpness(image: image) * 6   // 0–60
        score += computeBrightness(image: image) * 3  // 0–30
        
        // Face metrics: medium weight
        let face = await analyzeFace(image: image)
        score += face.poseScore * 4                   // 0–20
        score += face.smileScore * 3                  // 0–15
        score += face.eyesOpenScore * 2               // 0–10
        
        return score // max ~135
    }
    
    private func computeSharpness(image: UIImage) -> Int {
        guard let ci = CIImage(image: image) else { return 0 }

        // Try Laplacian (iOS 17+)
        let laplacian = CIFilter(name: "CILaplacian") ??
                        CIFilter(name: "CIUnsharpMask")  // fallback iOS 15/16

        guard let filter = laplacian else { return 0 }
        filter.setValue(ci, forKey: kCIInputImageKey)

        guard let output = filter.outputImage else { return 0 }

        let result = output.applyingFilter(
            "CIAreaMaximum",
            parameters: [kCIInputExtentKey: CIVector(cgRect: ci.extent)]
        )
        
        let context = CIContext()
        var pixel: UInt8 = 0

        context.render(
            result,
            toBitmap: &pixel,
            rowBytes: 1,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .L8,
            colorSpace: nil
        )
        
        return Int(pixel) / 25
    }
    
    private func computeBrightness(image: UIImage) -> Int {
        autoreleasepool {
            guard let cg = image.cgImage else { return 0 }
            let ci = CIImage(cgImage: cg)
            let context = CIContext()
            guard let bitmap = context.createCGImage(ci, from: ci.extent),
                  let data = bitmap.dataProvider?.data,
                  let ptr = CFDataGetBytePtr(data)
            else { return 0 }
            
            let length = CFDataGetLength(data)
            var total: Double = 0
            for i in stride(from: 0, to: length, by: 4) { total += Double(ptr[i]) / 255.0 }
            let avg = total / Double(length / 4)
            return Int(avg * 10)
        }
    }
    
    private func analyzeFace(image: UIImage) async -> (poseScore: Int, smileScore: Int, eyesOpenScore: Int) {
        await withCheckedContinuation { cont in
            guard let cgImage = image.cgImage else { return cont.resume(returning: (0,0,0)) }
            
            let request = VNDetectFaceLandmarksRequest { request, _ in
                guard let face = (request.results as? [VNFaceObservation])?.first else {
                    cont.resume(returning: (0,0,0))
                    return
                }
                
                var poseScore = 0
                var smileScore = 0
                var eyesOpenScore = 0
                
                // Pose: straight face
                if let roll = face.roll?.doubleValue, abs(roll) < 0.2 { poseScore = 5 }
                
                // Smile: simple metric
                if let lips = face.landmarks?.outerLips, lips.pointCount > 5 { smileScore = 5 }
                
                // Eyes open
                if let left = face.landmarks?.leftEye, let right = face.landmarks?.rightEye {
                    if left.pointCount > 4 && right.pointCount > 4 { eyesOpenScore = 5 }
                }
                
                cont.resume(returning: (poseScore, smileScore, eyesOpenScore))
            }
            
            Task.detached(priority: .userInitiated) {
                try? VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])
            }
        }
    }
}
