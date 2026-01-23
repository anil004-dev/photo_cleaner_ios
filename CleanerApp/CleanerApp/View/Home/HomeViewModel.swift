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
    
    func onAppear(mediaDatabase: MediaDatabase) {
        self.mediaDatabase = mediaDatabase
        self.fetchMedias()
    }
    
    func btnCategoryAction(category: MediaCategoryModel) {
        let destination = MediaListDestination(viewModel: MediaItemsListViewModel(mediaCategory: category))
        NavigationManager.shared.push(to: .mediaListView(destination: destination))
    }
    
    func btnSimilarMediaAction(category: SimilarMediaCategoryModel) {
        let destination = SimilarMediaListDestination(viewModel: SimilarMediaListViewModel(similarMediaCategory: category))
        NavigationManager.shared.push(to: .similarMediaListView(destination: destination))
    }
}

extension HomeViewModel {
    
    func fetchMedias() {
        Task {
            if await PhotoLibraryManager.shared.checkPermission() {
                mediaDatabase?.startScan()
            }
        }
    }
}
