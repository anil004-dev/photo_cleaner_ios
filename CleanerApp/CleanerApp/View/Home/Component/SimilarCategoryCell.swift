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
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                CNText(title: category.title, color: .white, font: .system(size: 16, weight: .medium), alignment: .leading)
                ZStack {
                    let mediaItem = category.arrSimilarMedias.first?.arrMediaItems
                    let width = ((UIScreen.main.bounds.width - 85) / 2)
                    
                    if let first = mediaItem?[0], let second = mediaItem?[1] {
                        HStack(spacing: 15) {
                            CNMediaThumbImage(mediaItem: first, size: CGSize(width: width, height: 150))
                                .cornerRadius(10)
                            
                            CNMediaThumbImage(mediaItem: second, size: CGSize(width: width, height: 150))
                                .cornerRadius(10)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        if mediaItem != nil {
                            Spacer()
                        }
                        
                        HStack(alignment: .center, spacing: 0) {
                            HStack(alignment: .center, spacing: 10) {
                                VStack(alignment: .leading, spacing: 5) {
                                    CNText(title: Utility.formattedSize(byte: category.totalSize), color: .white, font: .system(size: 13, weight: .medium, design: .default), alignment: .leading)
                                    
                                    CNText(title: "\(category.arrSimilarMedias.count) \(category.title)", color: .white, font: .system(size: 12, weight: .regular, design: .default), alignment: .leading)
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
                            
                            Spacer(minLength: 0)
                        }
                        .padding(mediaItem == nil ? 0 : 10)
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
