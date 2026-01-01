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
    
    init(similarMediaCategory: SimilarMediaCategoryModel) {
        _similarMediaCategory = Published(initialValue: similarMediaCategory)
    }
    
    func onAppear(mediaDatabase: MediaDatabase) {
        self.mediaDatabase = mediaDatabase
        self.btnSelectAllAction()
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
    
    func btnAllSelectItem(similar: SimilarMedia) {
        withAnimation {
            let firstItem = similar.arrMediaItems.first
            let arrMediaItems = similar.arrMediaItems.dropFirst()
            arrSelectedItems.append(contentsOf: arrMediaItems)
            
            var seen = Set<String>()
            arrSelectedItems = arrSelectedItems.filter { item in
                if firstItem?.assetId == item.assetId {
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
    
    func btnSelectAllAction() {
        withAnimation {
            let selected = similarMediaCategory.arrSimilarMedias.flatMap { group in
                Array(group.arrMediaItems.dropFirst())
            }
            
            arrSelectedItems = selected
        }
    }

    func btnDeleteAction() {
        guard !arrSelectedItems.isEmpty else { return }
        
        do {
            try mediaDatabase?.deleteMediaItems(arrSelectedItems)
            let selectedIds = Set(arrSelectedItems.map { $0.assetId })
            arrSelectedItems = []
            
            similarMediaCategory.arrSimilarMedias = similarMediaCategory.arrSimilarMedias.compactMap { group in
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
            
            if similarMediaCategory.arrSimilarMedias.isEmpty {
                NavigationManager.shared.pop()
            }
        } catch {
            return
        }
    }
}
