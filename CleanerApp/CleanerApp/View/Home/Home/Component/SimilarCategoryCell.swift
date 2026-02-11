//
//  SimilarCategoryCell.swift
//  CleanerApp
//
//  Created by iMac on 15/12/25.
//


import SwiftUI

struct SimilarCategoryCell: View {
    
    @ObservedObject var category: SimilarMediaCategoryModel
    let onTap: () -> Void
    
    var body: some View {
        categorySection
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            let isScanning = category.isScanning
            let isEmpty = category.arrSimilarMedias.isEmpty
            
            HStack(alignment: .center, spacing: 0) {
                HStack(alignment: .center, spacing: 8) {
                    CNText(title: category.title, color: .txtBlack, font: .system(size: 20, weight: .semibold), alignment: .leading)
                    
                    Image(systemName: "chevron.right")
                        .resizable()
                        .scaledToFit()
                        .fontWeight(.bold)
                        .foregroundStyle(Color(hex: "80828A"))
                        .frame(width: 10, height: 15)
                }
                
                Spacer(minLength: 0)
                
                if isScanning || (!isScanning && !isEmpty) {
                    VStack(alignment: .trailing, spacing: 2) {
                        CNText(title: "\(category.formattedSize)", color: .txtBlack, font: .system(size: 12, weight: .heavy, design: .default), alignment: .trailing)
                        
                        CNText(title: "\(category.totalMediaCount) Photos", color: Color(hex: "80818A"), font: .system(size: 12, weight: .semibold, design: .default), alignment: .trailing)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            
            let mediaItems = category.arrSimilarMedias.first?.arrMediaItems
            let totalHorizontalPadding: CGFloat = (34 * 2) + 4
            let itemSpacing: CGFloat = 6
            let numberOfColumns: CGFloat = 3
            let availableWidth = UIScreen.main.bounds.width - totalHorizontalPadding - (itemSpacing * (numberOfColumns - 1))
            let itemWidth = availableWidth / numberOfColumns
            
            
            if !isScanning, let first = mediaItems?.first {
                HStack(alignment: .center, spacing: 6) {
                    
                    CNMediaThumbImage(mediaItem: first, size: CGSize(width: itemWidth, height: itemWidth))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    
                    if (mediaItems?.count ?? 0) >= 2 , let second = mediaItems?[1] {
                        CNMediaThumbImage(mediaItem: second, size: CGSize(width: itemWidth, height: itemWidth))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    
                    if (mediaItems?.count ?? 0) >= 3 , let third = mediaItems?[2] {
                        CNMediaThumbImage(mediaItem: third, size: CGSize(width: itemWidth, height: itemWidth))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            } else if isScanning {
                HStack(alignment: .center, spacing: 6) {
                    ForEach(1...Int(numberOfColumns), id: \.self) { _ in
                        CNShimmerEffectBox()
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .frame(width: itemWidth, height: itemWidth)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.primOrange, lineWidth: 2)
        )
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.primOrange)
                .offset(x: 3.5, y: 3.5)
        }
        .onTapGesture(perform: onTap)
        .padding(1)
    }
}
