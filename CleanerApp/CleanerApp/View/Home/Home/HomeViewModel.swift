//
//  HomeViewModel.swift
//  CleanerApp
//
//  Created by iMac on 03/12/25.
//

import Combine
import SwiftUI

final class HomeViewModel: ObservableObject {
    
    @Published var mediaDatabase: MediaDatabase?
    @Published var showPermissionSection: Bool = false
    
    func onAppear(mediaDatabase: MediaDatabase) {
        self.mediaDatabase = mediaDatabase
        self.fetchMedias()
    }
    
    func btnGoToSettingsAction() {
        Utility.openSettings()
    }
    
    func btnCategoryAction(category: MediaCategoryModel) {
        guard !category.isScanning else { return }
        let destination = MediaListDestination(viewModel: MediaItemsListViewModel(mediaCategory: category))
        NavigationManager.shared.push(to: .mediaListView(destination: destination))
    }
    
    func btnSimilarMediaAction(category: SimilarMediaCategoryModel) {
        guard !category.isScanning else { return }
        let destination = SimilarMediaListDestination(viewModel: SimilarMediaListViewModel(similarMediaCategory: category))
        NavigationManager.shared.push(to: .similarMediaListView(destination: destination))
    }
    
    func btnCompressVideoAction(category: MediaCategoryModel) {
        guard !category.isScanning else { return }
        NavigationManager.shared.push(to: .compressVideoList)
    }
}

extension HomeViewModel {
    
    func fetchMedias() {
        if PhotoLibraryManager.shared.isPermissionGranted() {
            Task.detached {
                if await PhotoLibraryManager.shared.checkPermission(showAlert: false) {
                    await self.mediaDatabase?.startScan()
                    
                    await MainActor.run {
                        self.showPermissionSection = false
                    }
                } else {
                    await MainActor.run {
                        self.showPermissionSection = true
                    }
                }
            }
        } else {
            showPermissionSection = true
        }
    }
}
