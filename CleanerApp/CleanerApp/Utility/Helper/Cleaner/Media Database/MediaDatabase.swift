//
//  MediaDatabase.swift
//  CleanerApp
//
//  Created by iMac on 05/12/25.
//

import SwiftUI
import PhotosUI
import Combine

// MARK: - Media Database
final class MediaDatabase: ObservableObject {
    
    static let shared = MediaDatabase()
    private init() {}
    
    // MARK: - Published properties
    
    @Published var scanState: MediaScanState = .idle
    @Published var photos =  MediaCategoryModel(type: .photos)
    @Published var screenshots = MediaCategoryModel(type: .screenshots)
    @Published var livePhotos = MediaCategoryModel(type: .livePhotos)
    @Published var videos = MediaCategoryModel(type: .videos)
    @Published var screenRecordings = MediaCategoryModel(type: .screenRecordings)
    @Published var largeVideos = MediaCategoryModel(type: .largeVideos)
    
    @Published var similarPhotos = SimilarMediaCategoryModel(type: .similarPhotos)
    @Published var similarScreenshots = SimilarMediaCategoryModel(type: .similarScreenshots)
    
    @Published var duplicatePhotos = SimilarMediaCategoryModel(type: .duplicatePhotos)
    @Published var duplicateScreenshots = SimilarMediaCategoryModel(type: .duplicateScreenshots)
    
    // MARK: - Internal storage
    private var allAssets: [MediaItem] = []
    
    // MARK: - Public API
    func startScan() {
        guard scanState != .scanning, scanState != .completed else { return }

        Task { @MainActor in
            scanState = .scanning
        }

        Task.detached(priority: .background) {
            await self.scanLibrary()
        }
    }

    // MARK: - Core Scan Logic
    private func scanLibrary() async {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        let assets = PHAsset.fetchAssets(with: options)
        var buffers: [MediaType: [MediaItem]] = [:]
        let chunkSize = 0

        for i in 0..<assets.count {
            let asset = assets.object(at: i)
            guard let resource = PHAssetResource.assetResources(for: asset).first else { continue }

            let mediaItem = createMediaItem(asset: asset, resource: resource)
            buffers[mediaItem.type, default: []].append(mediaItem)
            allAssets.append(mediaItem)

            if buffers.values.flatMap({ $0 }).count >= chunkSize {
                let chunk = buffers
                buffers.removeAll()

                await MainActor.run {
                    self.applyChunk(chunk)
                }
            }
        }

        await MainActor.run {
            self.applyChunk(buffers)
        }
        
        Task(priority: .background) {

            let photos = self.photos.items
            let screenshots = self.screenshots.items

            await withTaskGroup(of: Void.self) { group in

                group.addTask {
                    let res = await SimilarMediaManager.shared.findSimilarMediaGroups(in: photos)
                    await MainActor.run {
                        withAnimation { self.similarPhotos.arrSimilarMedias = res }
                    }
                }

                group.addTask {
                    let res = await SimilarMediaManager.shared.findSimilarMediaGroups(in: screenshots)
                    await MainActor.run {
                        withAnimation { self.similarScreenshots.arrSimilarMedias = res }
                    }
                }

                group.addTask {
                    let res = await DuplicateMediaManager.shared.findExactDuplicateGroups(in: photos)
                    await MainActor.run {
                        withAnimation { self.duplicatePhotos.arrSimilarMedias = res }
                    }
                }

                group.addTask {
                    let res = await DuplicateMediaManager.shared.findExactDuplicateGroups(in: screenshots)
                    await MainActor.run {
                        withAnimation { self.duplicateScreenshots.arrSimilarMedias = res }
                    }
                }
            }

            await MainActor.run {
                self.scanState = .completed
            }
        }
    }
    
    @MainActor
    private func applyChunk(_ chunk: [MediaType: [MediaItem]]) {
        withAnimation {
            if let v = chunk[.photos] { photos.items.append(contentsOf: v) }
            if let v = chunk[.screenshots] { screenshots.items.append(contentsOf: v) }
            if let v = chunk[.livePhotos] { livePhotos.items.append(contentsOf: v) }
            if let v = chunk[.videos] { videos.items.append(contentsOf: v) }
            if let v = chunk[.screenRecordings] { screenRecordings.items.append(contentsOf: v) }
            if let v = chunk[.largeVideos] { largeVideos.items.append(contentsOf: v) }
        }
    }
    
    // MARK: - MediaItem Creation
    func createMediaItem(asset: PHAsset, resource: PHAssetResource) -> MediaItem {
        let fileSize = (resource.value(forKey: "fileSize") as? Int64) ?? 0
        let mediaType = PHAssetMediaType(rawValue: asset.mediaType.rawValue) ?? .unknown
        let subtypes = PHAssetMediaSubtype(rawValue: asset.mediaSubtypes.rawValue)
        
        var type: MediaType {
            if mediaType == .image && subtypes.contains(.photoScreenshot) { return .screenshots }
            if mediaType == .image && subtypes.contains(.photoLive) { return .livePhotos }
            if mediaType == .video && subtypes.contains(.videoScreenRecording) { return .screenRecordings }
            if mediaType == .video && fileSize > 200 * 1024 * 1024 { return .largeVideos }
            if mediaType == .video { return .videos }
            return .photos
        }
        
        var url: URL? {
            if type == .screenRecordings || type == .videos || type == .largeVideos {
                return self.getThumbnailURL(phAsset: asset)
            } else {
                return URL(string: "ph://\(asset.localIdentifier)")
            }
        }
        
        return MediaItem(
            asset: asset,
            type: type,
            fileSize: fileSize,
            assetId: asset.localIdentifier,
            filename: resource.originalFilename,
            creationDate: asset.creationDate,
            isFavourite: asset.isFavorite,
            mediaTypeRaw: asset.mediaType.rawValue,
            mediaSubtypesRaw: asset.mediaSubtypes.rawValue,
            thumbnailURL: url
        )
    }
    
    func addMediaItem(phAsset: PHAsset) {
        guard let resource = PHAssetResource.assetResources(for: phAsset).first else {
            return
        }
        
        let mediaItem = createMediaItem(asset: phAsset, resource: resource)
        allAssets.append(mediaItem)
        applyChunk([mediaItem.type: [mediaItem]])
    }
    
    func saveImageToGallery(
        from tempURL: URL
    ) async throws{

        var placeholder: PHObjectPlaceholder?

        try await PHPhotoLibrary.shared().performChanges {
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .photo, fileURL: tempURL, options: nil)
            placeholder = request.placeholderForCreatedAsset
        }

        guard let assetId = placeholder?.localIdentifier else {
            throw NSError(
                domain: "SaveImage",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to get asset identifier"]
            )
        }

        let result = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)

        guard let asset = result.firstObject else {
            throw NSError(
                domain: "SaveImage",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Failed to fetch saved PHAsset"]
            )
        }

        addMediaItem(phAsset: asset)
    }
    
    func fetchMediaCategory(type: MediaType) -> MediaCategoryModel {
        switch type {
        case .photos: return photos
        case .screenshots: return screenshots
        case .livePhotos: return livePhotos
        case .videos: return videos
        case .screenRecordings: return screenRecordings
        case .largeVideos: return largeVideos
        }
    }
    
    func fetchSimilarMediaCategory(type: SimilarMediaType) -> SimilarMediaCategoryModel {
        switch type {
        case .similarPhotos: return similarPhotos
        case .similarScreenshots: return similarScreenshots
        case .duplicatePhotos: return duplicatePhotos
        case .duplicateScreenshots: return duplicateScreenshots
        }
    }
    
    func deleteMediaItems(_ items: [MediaItem]) throws {
        let identifiers = items.map { $0.assetId }
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
        
        try PHPhotoLibrary.shared().performChangesAndWait {
            PHAssetChangeRequest.deleteAssets(assets)
        }
        
        allAssets.removeAll(where: { item in items.contains(where: { $0.assetId == item.assetId }) } )
        photos.items.removeAll(where: { item in items.contains(where: { $0.assetId == item.assetId }) })
        livePhotos.items.removeAll(where: { item in items.contains(where: { $0.assetId == item.assetId }) })
        screenshots.items.removeAll(where: { item in items.contains(where: { $0.assetId == item.assetId }) })
        videos.items.removeAll(where: { item in items.contains(where: { $0.assetId == item.assetId }) })
        screenRecordings.items.removeAll(where: { item in items.contains(where: { $0.assetId == item.assetId }) })
        largeVideos.items.removeAll(where: { item in items.contains(where: { $0.assetId == item.assetId }) })
        
        let selectedIds = items.compactMap({ $0.assetId })
        similarPhotos.arrSimilarMedias = similarPhotos.arrSimilarMedias.compactMap { group in
            let filteredItems = group.arrMediaItems.filter { !selectedIds.contains($0.assetId) }
            guard filteredItems.count > 1 else {
                return nil
            }
            
            return SimilarMedia(
                title: group.title,
                bestMediaAssetId: filteredItems.first!.assetId,
                arrMediaItems: filteredItems
            )
        }
        
        similarScreenshots.arrSimilarMedias = similarScreenshots.arrSimilarMedias.compactMap { group in
            let filteredItems = group.arrMediaItems.filter { !selectedIds.contains($0.assetId) }
            guard filteredItems.count > 1 else {
                return nil
            }
            
            return SimilarMedia(
                title: group.title,
                bestMediaAssetId: filteredItems.first!.assetId,
                arrMediaItems: filteredItems
            )
        }
    }
}

// MARK: - Thumbnail
extension MediaDatabase {
    func getThumbnailURL(phAsset: PHAsset) -> URL? {
        let thumbURL = thumbnailPath(for: phAsset)

        if FileManager.default.fileExists(atPath: thumbURL.path) {
            print("📁 Using existing thumbnail:", thumbURL.lastPathComponent)
            return thumbURL
        }

        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .fastFormat
        options.resizeMode = .fast

        var imageData: Data?
        PHImageManager.default().requestImageDataAndOrientation(
            for: phAsset,
            options: options
        ) { data, _, _, _ in
            imageData = data
        }

        guard let data = imageData else {
            return nil
        }

        do {
            try data.write(to: thumbURL)
            print("✅ Thumbnail saved:", thumbURL.lastPathComponent)
            return thumbURL
        } catch {
            print("❌ Failed to save thumbnail:", error)
            return nil
        }
    }
    
    func thumbnailPath(for asset: PHAsset) -> URL {
        let rawName = asset.localIdentifier
        let safeName = rawName
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")

        let fileName = safeName + ".jpg"

        let folder = FileManager.default
            .temporaryDirectory
            .appendingPathComponent("thumbnails", isDirectory: true)

        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }

        return folder.appendingPathComponent(fileName)
    }
}
