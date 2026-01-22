//
//  SimilarMedia.swift
//  CleanerApp
//
//  Created by iMac on 08/12/25.
//

import Foundation
import Combine

enum SimilarMediaType: String, CaseIterable, Identifiable {
    case similarPhotos
    case similarScreenshots
    case duplicatePhotos
    case duplicateScreenshots
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .similarPhotos: return "Similar Photos"
        case .similarScreenshots: return "Similar Screenshots"
        case .duplicatePhotos: return "Duplicate Photos"
        case .duplicateScreenshots: return "Duplicate Screenshots"
        }
    }
}


class SimilarMediaCategoryModel: ObservableObject, Identifiable {
    let id = UUID()
    var type: SimilarMediaType
    @Published var arrSimilarMedias: [SimilarMedia] = []
    
    var title: String { type.title }
    var totalSize: Int64 {
        return arrSimilarMedias.reduce(0) { sum, similar in
            sum + similar.arrMediaItems.reduce(0) {
                $0 + $1.fileSize
            }
        }
    }
    
    var totalMediaCount: Int {
        arrSimilarMedias.reduce(0) { sum, similar in
            sum + similar.arrMediaItems.count
        }
    }
    
    init(type: SimilarMediaType) {
        self.type = type
    }
    
    static func == (lhs: SimilarMediaCategoryModel, rhs: SimilarMediaCategoryModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct SimilarMedia: Identifiable {
    let id = UUID()
    
    /// Display title (ex: "5 Similar Photos")
    let title: String
    
    /// Asset ID chosen as the best representative (largest / sharpest / newest)
    let bestMediaAssetId: String?
    
    /// All similar media items
    var arrMediaItems: [MediaItem]
    
    /// Computed helpers (cheap + UI-friendly)
    var count: Int {
        arrMediaItems.count
    }
    
    var totalSize: Int64 {
        arrMediaItems.reduce(0) { $0 + $1.fileSize }
    }
    
    static func == (lhs: SimilarMedia, rhs: SimilarMedia) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
