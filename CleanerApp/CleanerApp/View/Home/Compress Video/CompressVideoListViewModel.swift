//
//  CompressVideoListViewModel.swift
//  CleanerApp
//
//  Created by iMac on 29/01/26.
//

import Combine
import Foundation

class CompressVideoListViewModel: ObservableObject {
    
    @Published var mediaDatabase: MediaDatabase?
    @Published var sortType: MediaItemSortType = .date
    @Published var arrItems: [MediaItem] = []
    
    func update(from mediaDatabase: MediaDatabase) {
        arrItems = mediaDatabase.compressVideos.items
        sortItems()
    }
    
    // MARK: - Actions
    func selectSortType(type: MediaItemSortType) {
        sortType = type
        sortItems()
    }
    
    func sortItems() {
        switch sortType {
        case .name:
            arrItems.sort { $0.filename.lowercased() < $1.filename.lowercased() }
        case .size:
            arrItems.sort { $0.fileSize > $1.fileSize }
        case .date:
            arrItems.sort { ($0.creationDate ?? .distantPast) > ($1.creationDate ?? .distantPast) }
        }
    }
    
    func btnMediaAction(media: MediaItem, compressInfo: VideoCompressionInfo) {
        NavigationManager.shared.push(to: .compressVideoOption(destination: CompressVideoOptionDestination(mediaItem: media, compressInfo: compressInfo)))
    }
}
