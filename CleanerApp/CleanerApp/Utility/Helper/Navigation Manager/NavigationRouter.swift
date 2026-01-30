//
//  NavigationRouter.swift
//  CleanerApp
//
//  Created by IMac on 03/12/25.
//

import SwiftUI

enum NavigationRouter {
    
    @ViewBuilder
    static func destinationView(for navDestination: NavigationDestination) -> some View {
        switch navDestination {
        case .none:
            EmptyView()
        case .onboardingView:
            OnboardingView()
            
        case .mediaListView(let destination):
            MediaItemsListView(viewModel: destination.viewModel)
            
        case .mediaPreviewView(let destination):
            MediaPreviewView(viewModel: destination.viewModel)
            
        case .stillPhotoPreviewView(let destination):
            StillPhotoPreviewView(viewModel: destination.viewModel)
            
        case .similarMediaListView(let destination):
            SimilarMediaListView(viewModel: destination.viewModel)
            
        case .duplicateContactGroupView(let destination):
            DuplicateContactGroupView(viewModel: destination.viewModel)
            
        case .duplicateMergePreview(let destination):
            DuplicateMergePreview(viewModel: destination.viewModel)
            
        case .incompleteContactListView(let destination):
            IncompleteContactListView(viewModel: destination.viewModel)
            
        case .backupContactView:
            BackupContactView()
            
        case .allContactsView:
            AllContactsView()
            
        case .chargingAnimationPreviewView(let destination):
            ChargingAnimationPreviewView(viewModel: destination.viewModel)
            
        case .compressVideoOption(let destination):
            CompressVideoOptionView(mediaItem: destination.mediaItem, compressInfo: destination.compressInfo)
            
        case .widgetListView:
            WidgetListView()
            
        case .speedTestView:
            SpeetTestView()
        }
    }
}
