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
        case .mediaListView(let destination):
            MediaItemsListView(viewModel: destination.viewModel)
        case .mediaPreviewView(let destination):
            MediaPreviewView(viewModel: destination.viewModel)
        case .similarMediaListView(let destination):
            SimilarMediaListView(viewModel: destination.viewModel)
        case .duplicateContactMenuView(let destination):
            DuplicateContactMenuView(viewModel: destination.viewModel)
        case .duplicateContactGroupView(let destination):
            DuplicateContactGroupView(viewModel: destination.viewModel)
        case .duplicateMergePreview(let destination):
            DuplicateMergePreview(viewModel: destination.viewModel)
        case .incompleteContactMenuView(let destination):
            IncompleteContactMenuView(viewModel: destination.viewModel)
        case .incompleteContactListView(let destination):
            IncompleteContactListView(viewModel: destination.viewModel)
        case .editIncompleteContactView(let destination):
            EditIncompleteContactView(viewModel: destination.viewModel)
        case .backupContactView:
            BackupContactView()
        case .allContactsView:
            AllContactsView()
        case .chargingAnimationPreviewView(let destination):
            ChargingAnimationPreviewView(viewModel: destination.viewModel)
        }
    }
}
