//
//  MediaItemsListViewModel.swift
//  CleanerApp
//
//  Created by iMac on 03/12/25.
//

import Combine
import SwiftUI

@MainActor
class MediaItemsListViewModel: ObservableObject {
    
    var mediaDatabase: MediaDatabase?
    
    @Published var sortType: MediaItemSortType = .date
    @Published var mediaCategory: MediaCategoryModel = MediaCategoryModel(type: .photos)
    
    @Published var arrItems: [MediaItem] = []
    @Published var arrSelectedItems: [MediaItem] = []
    
    @Published var showLivePhotoPreviewView: (sheet: Bool, arrImageURLs: [URL]) = (false, [])
    
    init(mediaCategory: MediaCategoryModel) {
        self.mediaCategory = mediaCategory
    }
    
    func onAppear(mediaDatabase: MediaDatabase) {
        self.mediaDatabase = mediaDatabase
        sortItems()
    }
    
    func sortItems() {
        if let mediaDatabase = mediaDatabase {
            self.mediaCategory = mediaDatabase.fetchMediaCategory(type: mediaCategory.type)
            self.arrItems = mediaCategory.items
            
            switch sortType {
            case .name:
                arrItems.sort { $0.filename.lowercased() < $1.filename.lowercased() }
            case .size:
                arrItems.sort { $0.fileSize > $1.fileSize }
            case .date:
                arrItems.sort { ($0.creationDate ?? .distantPast) > ($1.creationDate ?? .distantPast) }
            }
        }
    }
    
    // MARK: - Actions
    func selectSortType(type: MediaItemSortType) {
        sortType = type
        sortItems()
    }
    
    func selectItem(media: MediaItem) {
        withAnimation {
            if let index = arrSelectedItems.firstIndex(where: { $0.id == media.id }) {
                arrSelectedItems.remove(at: index)
            } else {
                arrSelectedItems.append(media)
            }
        }
    }
    
    func openMediaPreview(media: MediaItem) {
        let viewModel = MediaPreviewViewModel(
            mediaCategory: mediaCategory,
            arrItems: arrItems,
            currentMediaItem: media,
            arrSelectedItems: arrSelectedItems,
            onDoneBtnAction: { [weak self] arrSelectedItems in
                guard let self = self else { return }
                self.arrSelectedItems = arrSelectedItems
                NavigationManager.shared.pop()
            },
            onDeleteBtnAction: { [weak self] arrSelectedItems in
                guard let self = self else { return }
                self.arrSelectedItems = arrSelectedItems
                self.btnDeleteAction()
            },
            removeItems: { [weak self] arrItems in
                guard let self = self else { return }
                self.arrItems.removeAll { item in arrItems.contains(where: { $0.assetId == item.assetId }) }
                self.arrSelectedItems.removeAll { item in arrItems.contains(where: { $0.assetId == item.assetId }) }
            }
        )
        
        NavigationManager.shared.push(to: .mediaPreviewView(destination: MediaPreviewDestination(viewModel: viewModel)))
    }
    
    func btnDeleteAction() {
        guard !arrSelectedItems.isEmpty else { return }
        
        do {
            try mediaDatabase?.deleteMediaItems(arrSelectedItems)
            
            withAnimation {
                arrItems.removeAll(where: { item in arrSelectedItems.contains(where: { $0.assetId == item.assetId }) })
                arrSelectedItems = []
            }
            
            if arrItems.isEmpty {
                NavigationManager.shared.pop()
            }
        } catch {
            return
        }
    }
    
    func btnSelectAllAction() {
        withAnimation {
            if arrSelectedItems.isEmpty {
                arrSelectedItems = arrItems
            } else {
                arrSelectedItems = []
            }
        }
    }
    
    func btnConvertToStillAction(mediaItem: MediaItem) {
        CNLoader.show()
        
        Task {
            do {
                let arrImageURLs =  try await LivePhotoStillExtractor.shared.extractPreviewImageURLs(from: mediaItem)
                
                await MainActor.run {
                    CNLoader.dismiss()
                    self.showLivePhotoPreviewView.arrImageURLs = arrImageURLs
                    self.showLivePhotoPreviewView.sheet = true
                }
            } catch {
                await MainActor.run {
                    CNLoader.dismiss()
                    CNAlertManager.shared.showAlert(title: "Error occured", message: error.localizedDescription)
                }
            }
        }
    }
    
    func btnConvertStill(imageURL: URL) {
        self.showLivePhotoPreviewView = (false, [])
        
        Task {
            do {
                try await mediaDatabase?.saveImageToGallery(from: imageURL)
                
                await MainActor.run {
                    CNAlertManager.shared.showAlert(title: "Success", message: "Image saved to gallery succesfuly")
                }
            } catch let error {
                await MainActor.run {
                    CNAlertManager.shared.showAlert(title: "Error occured", message: error.localizedDescription)
                }
            }
        }
    }
}
