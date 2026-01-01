//
//  Array + Custom.swift
//  CleanerApp
//
//  Created by iMac on 16/12/25.
//

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [Array(self)] }
        return stride(from: 0, to: count, by: size).map { Array(self[$0..<Swift.min($0 + size, count)]) }
    }
}

extension Array where Element == SimilarMedia {
    
    /// Sort groups and items by creationDate (newest first)
    func sortedByNewest() -> [SimilarMedia] {
        
        return self
        // 1️⃣ Sort inside each group first
            .map { group in
                var g = group
                g.arrMediaItems = g.arrMediaItems.sorted {
                    ($0.creationDate ?? .distantPast) >
                    ($1.creationDate ?? .distantPast)
                }
                return g
            }
        // 2️⃣ Now sort groups by the newest item in each group
            .sorted { a, b in
                let aDate = a.arrMediaItems.first?.creationDate ?? .distantPast
                let bDate = b.arrMediaItems.first?.creationDate ?? .distantPast
                return aDate > bDate
            }
    }
    
    
    /// Sort groups + items by size (largest first)
    func sortedBySize() -> [SimilarMedia] {
        
        return self
            .map { group in
                var g = group
                g.arrMediaItems = g.arrMediaItems.sorted {
                    $0.fileSize > $1.fileSize
                }
                return g
            }
            .sorted { a, b in
                let aSize = a.arrMediaItems.first?.fileSize ?? 0
                let bSize = b.arrMediaItems.first?.fileSize ?? 0
                return aSize > bSize
            }
    }
}
