//
//  NavigationDestination.swift
//  CleanerApp
//
//  Created by IMac on 03/12/25.
//

import SwiftUI

enum NavigationDestination: Hashable {
    case none
    case onboardingView
    
    case mediaListView(destination: MediaListDestination)
    case mediaPreviewView(destination: MediaPreviewDestination)
    case similarMediaListView(destination: SimilarMediaListDestination)
    case duplicateContactMenuView(destination: DuplicateContactMenuDestination)
    case duplicateContactGroupView(destination: DuplicateContactGroupViewDestination)
    case duplicateMergePreview(destination: DuplicateMergePreviewDestination)
    case incompleteContactMenuView(destination: IncompleteContactMenuDestination)
    case incompleteContactListView(destination: IncompleteContactListDestination)
    case editIncompleteContactView(destination: EditIncompleteContactDestination)
    case backupContactView
    case allContactsView
    case chargingAnimationPreviewView(destination: ChargingAnimationPreviewDestination)
}

struct MediaListDestination: Hashable {
    let id = UUID()
    let viewModel: MediaItemsListViewModel
    
    static func == (lhs: MediaListDestination, rhs: MediaListDestination) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct MediaPreviewDestination: Hashable {
    let id = UUID()
    let viewModel: MediaPreviewViewModel
    
    static func == (lhs: MediaPreviewDestination, rhs: MediaPreviewDestination) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct SimilarMediaListDestination: Hashable {
    let id = UUID()
    let viewModel: SimilarMediaListViewModel
    
    static func == (lhs: SimilarMediaListDestination, rhs: SimilarMediaListDestination) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct DuplicateContactMenuDestination: Hashable {
    let id = UUID()
    let viewModel: DuplicateContactMenuViewModel
    
    static func == (lhs: DuplicateContactMenuDestination, rhs: DuplicateContactMenuDestination) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct DuplicateContactGroupViewDestination: Hashable {
    let id = UUID()
    let viewModel: DuplicateContactGroupViewModel
    
    static func == (lhs: DuplicateContactGroupViewDestination, rhs: DuplicateContactGroupViewDestination) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


struct DuplicateMergePreviewDestination: Hashable {
    let id = UUID()
    let viewModel: DuplicateMergePreviewModel
    
    static func == (lhs: DuplicateMergePreviewDestination, rhs: DuplicateMergePreviewDestination) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct IncompleteContactMenuDestination: Hashable {
    let id = UUID()
    let viewModel: IncompleteContactMenuViewModel
    
    static func == (lhs: IncompleteContactMenuDestination, rhs: IncompleteContactMenuDestination) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct IncompleteContactListDestination: Hashable {
    let id = UUID()
    let viewModel: IncompleteContactListViewModel
    
    static func == (lhs: IncompleteContactListDestination, rhs: IncompleteContactListDestination) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct EditIncompleteContactDestination: Hashable {
    let id = UUID()
    let viewModel: EditIncompleteContactViewModel
    
    static func == (lhs: EditIncompleteContactDestination, rhs: EditIncompleteContactDestination) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct ChargingAnimationPreviewDestination: Hashable {
    let id = UUID()
    let viewModel: ChargingAnimationPreviewViewModel
    
    static func == (lhs: ChargingAnimationPreviewDestination, rhs: ChargingAnimationPreviewDestination) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
