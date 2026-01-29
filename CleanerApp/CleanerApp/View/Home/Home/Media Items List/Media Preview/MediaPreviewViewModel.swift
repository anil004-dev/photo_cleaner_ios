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
