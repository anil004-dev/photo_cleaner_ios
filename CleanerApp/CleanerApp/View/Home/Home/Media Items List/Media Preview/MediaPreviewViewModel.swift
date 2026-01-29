//
//  MediaPreviewViewModel.swift
//  CleanerApp
//
//  Created by iMac on 05/12/25.
//

import SwiftUI
import Combine
import Foundation

class MediaPreviewViewModel: ObservableObject {
    
    var title: String
    var mediaType: MediaType
    
    @Published var arrItems: [MediaItem] = []
    @Published var arrSelectedItems: [MediaItem] = []
    @Published var currentIndex: Int = 0
    
    var onDoneBtnAction: (([MediaItem]) -> Void)
    var onDeleteBtnAction: (([MediaItem]) -> Void)
    var removeItems: (([MediaItem]) -> Void)
    
    init(title: String, mediaType: MediaType, arrItems: [MediaItem], currentMediaItem: MediaItem, arrSelectedItems: [MediaItem], onDoneBtnAction: @escaping ([MediaItem]) -> Void, onDeleteBtnAction: @escaping ([MediaItem]) -> Void, removeItems: @escaping (([MediaItem]) -> Void)) {
        self.title = title
        self.mediaType = mediaType
        self._arrItems = Published(initialValue: arrItems)
        self._arrSelectedItems = Published(initialValue: arrSelectedItems)
        self.onDoneBtnAction = onDoneBtnAction
        self.onDeleteBtnAction = onDeleteBtnAction
        self.removeItems = removeItems
        scrollToItem(media: currentMediaItem)
    }
    
    func btnDoneAction() {
        onDoneBtnAction(arrSelectedItems)
    }
    
    func btnCompressVideo(mediaItem: MediaItem) {
        CNLoader.show()
        
        Task {
            do {
                let (compVideoURL, asset) = try await VideoCompressor.shared.compressVideo(
                    mediaItem: mediaItem,
                    quality: .medium
                )
                
                print(compVideoURL)
                MediaDatabase.shared.addMediaItem(phAsset: asset)
                
                Task { @MainActor in
                    CNLoader.dismiss()
                    CNAlertManager.shared.showAlert(
                        title: "Saved!!",
                        message: "Video compressed and saved sucessfuly",
                        leftButtonAction: { [weak self] in
                            guard let self = self else { return }
                            do {
                                try MediaDatabase.shared.deleteMediaItems([mediaItem])
                                removeItems([mediaItem])
                                
                                if let index = arrItems.firstIndex(where: { $0.assetId == mediaItem.assetId } ) {
                                    arrSelectedItems.removeAll(where: { $0.assetId == mediaItem.assetId })
                                    
                                    if arrItems.count == 1 {
                                        NavigationManager.shared.popToRoot()
                                    } else {
                                        arrItems.remove(at: index)
                                        
                                        let nextIndex: Int
                                        
                                        if index < arrItems.count {
                                            nextIndex = index
                                        } else {
                                            nextIndex = arrItems.count - 1
                                        }
                                        
                                        currentIndex = nextIndex
                                    }
                                }
                            } catch {
                                return
                            }
                        }
                    )
                }
            } catch let error {
                Task { @MainActor in
                    CNLoader.dismiss()
                    CNAlertManager.shared.showAlert(title: "Error occured", message: error.localizedDescription)
                }
            }
        }
    }
    
    func scrollToItem(media: MediaItem) {
        if let index = arrItems.firstIndex(where: { $0.assetId == media.assetId }) {
            self.currentIndex = index
        }
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
}
