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
    case duplicateContactGroupView(destination: DuplicateContactGroupViewDestination)
    case duplicateMergePreview(destination: DuplicateMergePreviewDestination)
    case incompleteContactListView(destination: IncompleteContactListDestination)
    case backupContactView
    case allContactsView
    case chargingAnimationPreviewView(destination: ChargingAnimationPreviewDestination)
    case stillPhotoPreviewView(destination: StillPhotoPreviewDestination)
    case compressVideoOption(destination: CompressVideoOptionDestination)
    case widgetListView
    case speedTestView
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

struct StillPhotoPreviewDestination: Hashable {
    let id = UUID()
    let viewModel: StillPhotoPreviewModel
    
    static func == (lhs: StillPhotoPreviewDestination, rhs: StillPhotoPreviewDestination) -> Bool {
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

struct CompressVideoOptionDestination: Hashable {
    let id = UUID()
    let mediaItem: MediaItem
    let compressInfo: VideoCompressionInfo
    
    static func == (lhs: CompressVideoOptionDestination, rhs: CompressVideoOptionDestination) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
