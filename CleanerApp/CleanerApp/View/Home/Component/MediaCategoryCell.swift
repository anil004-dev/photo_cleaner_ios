//
//  MediaCategoryCell.swift
//  CleanerApp
//
//  Created by iMac on 15/12/25.
//

import SwiftUI

struct MediaCategoryCell: View {
    @ObservedObject var category: MediaCategoryModel
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                CNText(title: category.title, color: .white, font: .system(size: 16, weight: .medium), alignment: .leading)
                
                HStack(alignment: .center, spacing: 0) {
                    let items = category.items.sorted { ($0.creationDate ?? .distantPast) > ($1.creationDate ?? .distantPast) }
                    let firstItem = items.first
                    let size = CGSize(width: 90, height: 90)
                    
                    if let firstItem {
                        HStack(alignment: .center, spacing: 20) {
                            CNMediaThumbImage(mediaItem: firstItem, size: size)
                                .cornerRadius(10)
                            
                            if items.count >= 2 {
                                let secondItem = items[1]
                                CNMediaThumbImage(mediaItem: secondItem, size: size)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    
                    if firstItem != nil {
                        Spacer(minLength: 20)
                    }
                    
                    HStack(alignment: .center, spacing: 10) {
                        VStack(alignment: .leading, spacing: 5) {
                            CNText(title: Utility.formattedSize(byte: category.totalSize), color: .white, font: .system(size: 13, weight: .medium, design: .default), alignment: .leading)
                            
                            CNText(title: "\(category.count) \(category.title)", color: .white, font: .system(size: 12, weight: .regular, design: .default), alignment: .leading)
                        }
                        
                        Image(systemName: "chevron.right")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 10)
                    }
                    .padding(5)
                    .frame(alignment: .leading)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    
                    if firstItem == nil {
                        Spacer(minLength: 0)
                    }
                }
            }
            .padding(15)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.darkBlueCellBg)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onTapGesture {
            onTap()
        }
    }
}
