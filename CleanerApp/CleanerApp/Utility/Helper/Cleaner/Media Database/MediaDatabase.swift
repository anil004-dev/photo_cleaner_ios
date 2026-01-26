//
//  MediaDatabase.swift
//  CleanerApp
//
//  Created by iMac on 05/12/25.
//

import SwiftUI
import PhotosUI
import Combine
import Foundation

// MARK: - Media Database
final class MediaDatabase: ObservableObject {
    
    static let shared = MediaDatabase()
    private init() {}
    deinit {
        print("Deinti")
    }
    
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
    
    var usedStorage: Float {
        return Float(getTotalStorage().used)
    }
    
    var freeStorage: Float {
        return Float(getTotalStorage().free)
    }
    
    var totalStorage: Float {
        return Float(getTotalStorage().total)
    }
    
    var formattedUsedStorage: String {
        return Utility.formatStorage(bytes: usedStorage)
    }
    
    var formattedFreeStorage: String {
        return Utility.formatStorage(bytes: freeStorage)
    }
    
    var formattedTotalStorage: String {
        return Utility.formatStorage(bytes: totalStorage)
    }
    
    func getTotalStorage() -> (used: Int, free: Int, total: Int) {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return (0, 0,0)
        }
        
        do {
            let values = try url.resourceValues(forKeys: [
                .volumeTotalCapacityKey,
                .volumeAvailableCapacityKey
            ])
            
            guard let totalStorage = values.volumeTotalCapacity, let freeStorage = values.volumeAvailableCapacity else {
                return (0, 0,0)
            }
            
            let usedStorage = totalStorage - freeStorage
            
            return (usedStorage, freeStorage, totalStorage)
        } catch {
            return (0, 0,0)
        }
    }
    
    // MARK: - Internal storage
    private var allMediaItems: [MediaItem] = []
    
    // MARK: - Public API
    func startScan() {
        guard scanState != .scanning, scanState != .completed else {
            return
        }
        
        Task { @MainActor in
            scanState = .scanning
        }
        
        Task.detached(priority: .background) {
            await self.fetchAllItems()
        }
    }
    
    private func fetchItems(type: MediaType, completion: @escaping ([MediaItem]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            switch type {
                
            case .photos:
                // Only normal photos (no screenshots, no live)
                options.predicate = NSPredicate(
                    format: "mediaType == %d AND NOT (mediaSubtypes & %d != 0) AND NOT (mediaSubtypes & %d != 0)",
                    PHAssetMediaType.image.rawValue,
                    PHAssetMediaSubtype.photoScreenshot.rawValue,
                    PHAssetMediaSubtype.photoLive.rawValue
                )
                
            case .videos:
                // Only normal videos (no screen recordings)
                options.predicate = NSPredicate(
                    format: "mediaType == %d AND NOT (mediaSubtypes & %d != 0)",
                    PHAssetMediaType.video.rawValue,
                    PHAssetMediaSubtype.videoScreenRecording.rawValue
                )
                
            case .screenshots:
                options.predicate = NSPredicate(
                    format: "mediaSubtypes & %d != 0",
                    PHAssetMediaSubtype.photoScreenshot.rawValue
                )
                
            case .livePhotos:
                options.predicate = NSPredicate(
                    format: "mediaSubtypes & %d != 0",
                    PHAssetMediaSubtype.photoLive.rawValue
                )
                
            case .screenRecordings:
                options.predicate = NSPredicate(
                    format: "mediaSubtypes & %d != 0",
                    PHAssetMediaSubtype.videoScreenRecording.rawValue
                )
                
            case .largeVideos:
                let minSize = 200 * 1024 * 1024
                
                options.predicate = NSPredicate(
                    format: "mediaType == %d AND NOT (mediaSubtypes & %d != 0)",
                    PHAssetMediaType.video.rawValue,
                    minSize,
                    PHAssetMediaSubtype.videoScreenRecording.rawValue
                )
            }
            
            let fetchResult = PHAsset.fetchAssets(with: options)
            
            var items: [MediaItem] = []
            items.reserveCapacity(fetchResult.count)
            
            fetchResult.enumerateObjects { asset, _, _ in
                autoreleasepool {
                    let item = self.createMediaItem(
                        type: type,
                        asset: asset
                    )
                    
                    items.append(item)
                }
            }
            
            DispatchQueue.main.async {
                self.allMediaItems.append(contentsOf: items)
                completion(items)
            }
        }
    }
    
    private func fetchAllItems() {

        let group = DispatchGroup()

        func enter() { group.enter() }
        func leave() { group.leave() }

        enter()
        fetchPhotos { items in
            DispatchQueue.main.async {
                self.photos.setItems(arrItems: items)
            }
            
            leave()
        }

        enter()
        fetchScreenshots { items in
            DispatchQueue.main.async {
                self.screenshots.setItems(arrItems: items)
            }
            
            leave()
        }

        enter()
        fetchLivePhotos { items in
            DispatchQueue.main.async {
                self.livePhotos.setItems(arrItems: items)
            }
           
            leave()
        }

        enter()
        fetchVideos { items in
            DispatchQueue.main.async {
                self.videos.setItems(arrItems: items)
            }
           
            leave()
        }

        enter()
        fetchScreenRecordings { items in
            DispatchQueue.main.async {
                self.screenRecordings.setItems(arrItems: items)
            }
           
            leave()
        }

        enter()
        fetchLargeVideos { items in
            DispatchQueue.main.async {
                self.largeVideos.setItems(arrItems: items)
            }
           
            leave()
        }

        group.notify(queue: .global(qos: .background)) {
            Task(priority: .background) {
                self.fetchSimilarMedias()
                await MainActor.run {
                    self.scanState = .completed
                }
            }
        }
    }
    
    private func fetchPhotos(completion: (([MediaItem]) -> Void)? = nil) {
        fetchItems(type: .photos) { items in
            completion?(items)
        }
    }
    
    private func fetchScreenshots(completion: (([MediaItem]) -> Void)? = nil) {
        fetchItems(type: .screenshots) { items in
            completion?(items)
        }
    }
    
    private func fetchLivePhotos(completion: (([MediaItem]) -> Void)? = nil) {
        fetchItems(type: .livePhotos) { items in
            completion?(items)
        }
    }
    
    private func fetchVideos(completion: (([MediaItem]) -> Void)? = nil) {
        fetchItems(type: .videos) { items in
            completion?(items)
        }
    }
    
    private func fetchScreenRecordings(completion: (([MediaItem]) -> Void)? = nil) {
        fetchItems(type: .screenRecordings) { items in
            completion?(items)
        }
    }
    
    private func fetchLargeVideos(completion: (([MediaItem]) -> Void)? = nil) {
        fetchItems(type: .largeVideos) { items in
            completion?(items)
        }
    }
    
    private func fetchSimilarMedias(completion: (() -> Void)? = nil) {
        
        let photos = self.photos.items
        let screenshots = self.screenshots.items
        
        Task(priority: .background) {
            
            await withTaskGroup(of: (Int, [SimilarMedia]).self) { (group: inout TaskGroup<(Int, [SimilarMedia])>) in
                
                // 0 = similar photos
                group.addTask {
                    let similarMedias: [SimilarMedia] =
                    await SimilarMediaManager.shared
                        .findSimilarMediaGroups(in: photos)
                    
                    return (0, similarMedias)
                }
                
                // 1 = similar screenshots
                group.addTask {
                    let similarMedias: [SimilarMedia] =
                    await SimilarMediaManager.shared
                        .findSimilarMediaGroups(in: screenshots)
                    
                    return (1, similarMedias)
                }
                
                // 2 = duplicate photos
                group.addTask {
                    let similarMedias: [SimilarMedia] =
                    await DuplicateMediaManager.shared
                        .findExactDuplicateGroups(in: photos)
                    
                    return (2, similarMedias)
                }
                
                // 3 = duplicate screenshots
                group.addTask {
                    let similarMedias: [SimilarMedia] =
                    await DuplicateMediaManager.shared
                        .findExactDuplicateGroups(in: screenshots)
                    
                    return (3, similarMedias)
                }
                
                for await (type, similarMedias) in group {
                    
                    await MainActor.run {
                        
                        withAnimation(.easeOut(duration: 0.25)) {
                            
                            switch type {
                            case 0:
                                self.similarPhotos.setSimilarMedias(similarMedias: similarMedias)
                                
                            case 1:
                                self.similarScreenshots.setSimilarMedias(similarMedias: similarMedias)
                                
                            case 2:
                                self.duplicatePhotos.setSimilarMedias(similarMedias: similarMedias)
                                
                            case 3:
                                self.duplicateScreenshots.setSimilarMedias(similarMedias: similarMedias)
                                
                            default:
                                break
                            }
                        }
                    }
                }
            }
            
            await MainActor.run {
                completion?()
            }
        }
    }
    
    func createMediaItem(type: MediaType? = nil, asset: PHAsset, resource: PHAssetResource? = nil) -> MediaItem {
        let fileSize = (resource?.value(forKey: "fileSize") as? Int64) ?? 0
        let mediaType = asset.mediaType
        let subtypes = asset.mediaSubtypes
        let fileName = asset.value(forKey: "filename") as? String ?? ""
        
        var assumedType: MediaType {
            if mediaType == .image && subtypes.contains(.photoScreenshot) { return .screenshots }
            if mediaType == .image && subtypes.contains(.photoLive) { return .livePhotos }
            if mediaType == .video && subtypes.contains(.videoScreenRecording) { return .screenRecordings }
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
        
        let item = MediaItem(asset: asset, type: type ?? assumedType, fileSize: fileSize, assetId: asset.localIdentifier, filename: fileName, creationDate: asset.creationDate, isFavourite: asset.isFavorite, mediaTypeRaw: asset.mediaType.rawValue, mediaSubtypesRaw: asset.mediaSubtypes.rawValue, thumbnailURL: url)
        
        return item
    }
    
    func deleteMediaItems(_ items: [MediaItem]) throws {
        let identifiers = items.map { $0.assetId }
        let selectedIds = items.compactMap({ $0.assetId })
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
        
        try PHPhotoLibrary.shared().performChangesAndWait {
            PHAssetChangeRequest.deleteAssets(assets)
        }
        
        allMediaItems.removeAll(where: { item in items.contains(where: { $0.assetId == item.assetId }) } )
        photos.items.removeAll(where: { item in items.contains(where: { $0.assetId == item.assetId }) })
        livePhotos.items.removeAll(where: { item in items.contains(where: { $0.assetId == item.assetId }) })
        screenshots.items.removeAll(where: { item in items.contains(where: { $0.assetId == item.assetId }) })
        videos.items.removeAll(where: { item in items.contains(where: { $0.assetId == item.assetId }) })
        screenRecordings.items.removeAll(where: { item in items.contains(where: { $0.assetId == item.assetId }) })
        largeVideos.items.removeAll(where: { item in items.contains(where: { $0.assetId == item.assetId }) })
        
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

// MARK: - Operations
extension MediaDatabase {
    
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
    
    func addMediaItem(phAsset: PHAsset) {
        guard let resource = PHAssetResource.assetResources(for: phAsset).first else {
            return
        }
        
        let mediaItem = createMediaItem(asset: phAsset, resource: resource)
        allMediaItems.append(mediaItem)
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
}

// MARK: - Thumbnail
extension MediaDatabase {
    func getThumbnailURL(phAsset: PHAsset) -> URL? {
        let thumbURL = thumbnailPath(for: phAsset)
        
        if FileManager.default.fileExists(atPath: thumbURL.path) {
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
