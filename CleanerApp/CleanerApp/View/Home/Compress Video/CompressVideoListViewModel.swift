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
    
    func onAppear(mediaDatabase: MediaDatabase) {
        self.mediaDatabase = mediaDatabase
        self.sortItems()
    }
    
    // MARK: - Actions
    func selectSortType(type: MediaItemSortType) {
        sortType = type
        sortItems()
    }
    
    func sortItems() {
        if let mediaDatabase = mediaDatabase {
            self.arrItems = (mediaDatabase.videos.items) + (mediaDatabase.screenRecordings.items)
            
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
    
    func btnMediaAction(media: MediaItem) {
        
    }
    
    func btnCompressVideo(mediaItem: MediaItem) {
        /*CNLoader.show()
        
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
        }*/
    }
    
}
