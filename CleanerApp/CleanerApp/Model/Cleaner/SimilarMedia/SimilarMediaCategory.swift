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
    @Published var isScanning: Bool = true
    
    var title: String { type.title }
    var totalSize: Int64 {
        return arrSimilarMedias.reduce(0) { sum, similar in
            sum + similar.arrMediaItems.reduce(0) {
                $0 + $1.fileSize
            }
        }
    }
    
    var formattedSize: String {
        Utility.formattedSize(byte: totalSize)
    }
    
    var totalMediaCount: Int {
        arrSimilarMedias.reduce(0) { sum, similar in
            sum + similar.arrMediaItems.count
        }
    }
    
    init(type: SimilarMediaType) {
        self.type = type
    }
    
    func setSimilarMedias(similarMedias: [SimilarMedia]) {
        arrSimilarMedias = similarMedias
        isScanning = false
        calculateSize()
    }
    
    func calculateSize() {
        guard !arrSimilarMedias.isEmpty else { return }

        DispatchQueue.global(qos: .background).async {
            for (i, media) in self.arrSimilarMedias.enumerated() {
                for (j, item) in media.arrMediaItems.enumerated() {
                    let size = item.asset.fileSizeSync()
                    
                    DispatchQueue.main.async {
                        self.arrSimilarMedias[i].arrMediaItems[j].fileSize = size
                    }
                }
            }
        }
    }
    
    /*func calculateSize() {
        
        guard !arrSimilarMedias.isEmpty else { return }
        
        
        Task(priority: .utility) {
            
            var updatedGroups = self.arrSimilarMedias
            
            await withTaskGroup(of: (Int, Int, Int64).self) { taskGroup in
                
                for (groupIndex, similarGroup) in self.arrSimilarMedias.enumerated() {
                    
                    for (itemIndex, item) in similarGroup.arrMediaItems.enumerated() {
                        taskGroup.addTask {
                            let size = await item.asset.fileSizeAsync(completion: <#(Int64) -> Void#>)
                            return (groupIndex, itemIndex, size)
                        }
                    }
                }
                
                for await (groupIndex, itemIndex, size) in taskGroup {
                    updatedGroups[groupIndex]
                        .arrMediaItems[itemIndex]
                        .fileSize = size
                }
            }
            
            await MainActor.run {
                self.arrSimilarMedias = updatedGroups
            }
        }
    }*/
    
    static func == (lhs: SimilarMediaCategoryModel, rhs: SimilarMediaCategoryModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct SimilarMedia: Identifiable, Hashable {
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
    
    var formattedSize: String {
        Utility.formattedSize(byte: totalSize)
    }
    
    static func == (lhs: SimilarMedia, rhs: SimilarMedia) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
