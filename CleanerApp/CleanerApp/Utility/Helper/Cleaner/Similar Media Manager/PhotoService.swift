//
//  PhotoService.swift
//  CleanerApp
//
//  Created by iMac on 09/12/25.
//

import Photos
import UIKit

actor PhotoService {
    
    static let shared = PhotoService()
    private let manager = PHCachingImageManager()
    private init() {}
    
    // MARK: - Unified Image Loader
    func loadImage(
        asset: PHAsset,
        isSynchronous: Bool,
        isHighQuality: Bool,
        targetSize: CGSize,
        contentMode: PHImageContentMode = .aspectFit
    ) async -> UIImage? {
        
        await withCheckedContinuation { cont in
            let opt = PHImageRequestOptions()
            opt.isSynchronous = isSynchronous
            opt.isNetworkAccessAllowed = true
            opt.deliveryMode = !isHighQuality ? .fastFormat : .highQualityFormat
            opt.resizeMode = !isHighQuality ? .fast : .exact
            
            manager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: contentMode,
                options: opt
            ) { img, _ in
                cont.resume(returning: img)
            }
        }
    }
    
    // MARK: - Filename + path helpers
    private func fileName(for asset: PHAsset) -> String {
        return asset.localIdentifier
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_") + ".jpg"
    }
    
    private func thumbnailPath(for asset: PHAsset) -> URL {
        let folder = FileManager.default.temporaryDirectory
            .appendingPathComponent("thumbnails", isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        
        return folder.appendingPathComponent(fileName(for: asset))
    }
    
    // MARK: - Thumbnail URL (Unified)
    func thumbnailURL(asset: PHAsset, size: CGSize = CGSize(width: 128, height: 128)) async -> URL? {
        
        let path = thumbnailPath(for: asset)
        
        // 1) Return existing thumbnail
        if FileManager.default.fileExists(atPath: path.path) {
            print("📁 Using existing thumbnail:", path.lastPathComponent)
            return path
        }
        
        // 2) Generate new low-res image
        guard let img = await loadImage(asset: asset, isSynchronous: true, isHighQuality: false, targetSize: size),
              let data = img.jpegData(compressionQuality: 1.0) else {
            return nil
        }
        
        // 3) Save to disk
        do {
            try data.write(to: path)
            print("✅ Saved new thumbnail:", path.lastPathComponent)
            return path
        } catch {
            print("❌ Error saving thumbnail:", error)
            return nil
        }
    }
}
