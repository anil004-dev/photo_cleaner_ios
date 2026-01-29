//
//  SimilarMediaListViewModel.swift
//  CleanerApp
//
//  Created by iMac on 08/12/25.
//

import SwiftUI
import Combine

@MainActor
class SimilarMediaListViewModel: ObservableObject {
    
    var mediaDatabase: MediaDatabase?
    @Published var similarMediaCategory: SimilarMediaCategoryModel
    @Published var arrSelectedItems: [MediaItem] = []
    @Published var sortType: MediaItemSortType = .date
    
    init(similarMediaCategory: SimilarMediaCategoryModel) {
        _similarMediaCategory = Published(initialValue: similarMediaCategory)
        sortItems()
        btnSelectAllAction()
    }
    
    func onAppear(mediaDatabase: MediaDatabase) {
        self.mediaDatabase = mediaDatabase
    }
    
    func sortItems() {
        if let mediaDatabase = mediaDatabase {
            similarMediaCategory = mediaDatabase.fetchSimilarMediaCategory(type: similarMediaCategory.type)
            
            switch sortType {
            case .name:
                similarMediaCategory.arrSimilarMedias.sort { ($0.arrMediaItems.first?.filename.lowercased() ?? "") < ($1.arrMediaItems.first?.filename.lowercased() ?? "") }
            case .size:
                similarMediaCategory.arrSimilarMedias = similarMediaCategory.arrSimilarMedias.sortedBySize()
            case .date:
                similarMediaCategory.arrSimilarMedias = similarMediaCategory.arrSimilarMedias.sortedByNewest()
            }
        }
    }
    
    func deleteItems(mediaItems: [MediaItem], completion: @escaping (() -> Void)) {
        do {
            try mediaDatabase?.deleteMediaItems(mediaItems)
            let selectedIds = Set(mediaItems.map { $0.assetId })
            completion()
            
            similarMediaCategory.arrSimilarMedias = similarMediaCategory.arrSimilarMedias.compactMap { group in
                let filteredItems = group.arrMediaItems.filter { !selectedIds.contains($0.assetId) }
                guard filteredItems.count > 1 else {
                    return nil
                }
                
                return SimilarMedia(
                    title: group.title,
                    bestMediaAssetId: group.bestMediaAssetId,
                    arrMediaItems: filteredItems
                )
            }
            
            if similarMediaCategory.arrSimilarMedias.isEmpty {
                NavigationManager.shared.pop()
            }
        } catch {
            return
        }
    }
    
    func btnSelectItem(media: MediaItem) {
        withAnimation {
            if let index = arrSelectedItems.firstIndex(where: { $0.id == media.id }) {
                arrSelectedItems.remove(at: index)
            } else {
                arrSelectedItems.append(media)
            }
        }
    }
    
    func btnDeselectAllItems(similar: SimilarMedia) {
        withAnimation {
            arrSelectedItems.removeAll { selected in
                similar.arrMediaItems.contains { item in
                    item.assetId == selected.assetId
                }
            }
        }
    }
    
    func btnSelectAllItems(similar: SimilarMedia) {
        withAnimation {
            let arrMediaItems = similar.arrMediaItems.filter { $0.assetId != similar.bestMediaAssetId }
            arrSelectedItems.append(contentsOf: arrMediaItems)
            
            var seen = Set<String>()
            arrSelectedItems = arrSelectedItems.filter { item in
                if similar.bestMediaAssetId == item.assetId {
                    return false
                }
                
                if seen.contains(item.assetId) {
                    return false
                } else {
                    seen.insert(item.assetId)
                    return true
                }
            }
        }
    }
    
    func btnDeselectAllAction() {
        withAnimation {
            arrSelectedItems = []
        }
    }
    
    func btnSelectAllAction() {
        withAnimation {
            let selected = similarMediaCategory.arrSimilarMedias.flatMap { group in
                Array(group.arrMediaItems.filter { $0.assetId != group.bestMediaAssetId })
            }
            
            arrSelectedItems = selected
        }
    }

    func btnDeleteAction() {
        guard !arrSelectedItems.isEmpty else { return }
        deleteItems(mediaItems: arrSelectedItems) { [weak self] in
            self?.arrSelectedItems = []
        }
    }
    
    func openMediaPreview(media: MediaItem, similarMedia: SimilarMedia) {
        let viewModel = MediaPreviewViewModel(
            title: similarMediaCategory.title,
            mediaType: .photos,
            arrItems: similarMedia.arrMediaItems,
            currentMediaItem: media,
            arrSelectedItems: similarMedia.arrMediaItems.filter({ arrSelectedItems.contains($0) }),
            onDoneBtnAction: { [weak self] newSelectedItems in
                guard let self else { return }

                // Remove old versions
                self.arrSelectedItems.removeAll { item in
                    similarMedia.arrMediaItems.contains(where: { $0.assetId == item.assetId })
                }

                // Add updated ones
                self.arrSelectedItems.append(contentsOf: newSelectedItems)

                DispatchQueue.main.async {
                    NavigationManager.shared.pop()
                }
            },
            onDeleteBtnAction: { [weak self] arrSelectedItems in
                guard let self = self else { return }
                deleteItems(mediaItems: arrSelectedItems) { [weak self] in
                    self?.arrSelectedItems.removeAll(where: { arrSelectedItems.contains($0) })
                }
            },
            removeItems: { [weak self] arrItems in
                guard let self = self else { return }
                
                self.arrSelectedItems.removeAll { item in
                    arrItems.contains(where: { $0.assetId == item.assetId })
                }
            }
        )
        
        NavigationManager.shared.push(to: .mediaPreviewView(destination: MediaPreviewDestination(viewModel: viewModel)))
    }
}
