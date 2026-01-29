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
        mediaSection
    }
    
    private var mediaSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            let isScanning = category.isScanning
            let isEmpty = category.items.isEmpty
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .center, spacing: 8) {
                    CNText(title: category.title, color: .white, font: .system(size: 20, weight: .bold), alignment: .leading)
                    
                    Image(systemName: "chevron.right")
                        .resizable()
                        .scaledToFit()
                        .fontWeight(.bold)
                        .foregroundStyle(Color(hex: "80828A"))
                        .frame(width: 8, height: 13)
                }
                
                if isScanning || (!isScanning && !isEmpty) {
                    HStack(alignment: .center, spacing: 0) {
                        CNText(title: "\(category.count) \(category.title) • ", color: Color(hex: "80818A"), font: .system(size: 12, weight: .semibold, design: .default), alignment: .leading)
                        
                        CNText(title: "\(category.formattedSize)", color: .white, font: .system(size: 12, weight: .semibold, design: .default), alignment: .leading)
                    }
                }
            }
            .padding(.horizontal, 25)
            
            let mediaItems = category.items
            let totalHorizontalPadding: CGFloat = 20 * 2
            let itemSpacing: CGFloat = 10
            let numberOfColumns: CGFloat = 2
            let availableWidth = UIScreen.main.bounds.width - totalHorizontalPadding - (itemSpacing * (numberOfColumns - 1))
            let itemWidth = availableWidth / numberOfColumns
            
            if !isScanning, let first = mediaItems.first {
                HStack(alignment: .center, spacing: 10) {
                    CNMediaThumbImage(mediaItem: first, size: CGSize(width: itemWidth, height: itemWidth))
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                    
                    if (mediaItems.count) >= 2 {
                        let second = mediaItems[1]
                        
                        CNMediaThumbImage(mediaItem: second, size: CGSize(width: itemWidth, height: itemWidth))
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                    }
                }
                .padding(.horizontal, 20)
            } else if isScanning {
                HStack(alignment: .center, spacing: 10) {
                    CNShimmerEffectBox()
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .frame(width: itemWidth, height: itemWidth)
                    
                    CNShimmerEffectBox()
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .frame(width: itemWidth, height: itemWidth)
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color.bgDarkBlue)
        .clipShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}
