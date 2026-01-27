//
//  SimilarMediaListView.swift
//  CleanerApp
//
//  Created by iMac on 08/12/25.
//

import SwiftUI

struct SimilarMediaListView: View {
    
    @ObservedObject var viewModel: SimilarMediaListViewModel
    @EnvironmentObject var mediaDatabase: MediaDatabase
    
    var body: some View {
        ZStack {
            Color.bgDarkBlue.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                mediaItemsSection
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.btnDeselectAllAction()
                } label: {
                    HStack(alignment: .center, spacing: 5) {
                        Image(.icSqaureCheckmark)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                        
                        CNText(title: "Deselect All", color: .white, font: .system(size: 17, weight: .medium, design: .default), alignment: .center)
                    }
                    .padding(.horizontal, 10)
                    .clipShape(Rectangle())
                }
            }
        }
        .onAppear {
            viewModel.onAppear(mediaDatabase: mediaDatabase)
        }
    }
    
    private var mediaItemsSection: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                titleSection
                mediaItemListSection
                deleteButton
            }
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    CNText(title: viewModel.similarMediaCategory.title, color: .white, font: .system(size: 36, weight: .bold, design: .default), alignment: .leading)
                    
                    HStack(alignment: .top, spacing: 5) {
                        CNText(title: viewModel.similarMediaCategory.formattedSize, color: .white, font: .system(size: 12, weight: .semibold, design: .default), alignment: .leading)
                        
                        CNText(title: "(\(viewModel.similarMediaCategory.totalMediaCount) Photos)", color: .textGray, font: .system(size: 12, weight: .semibold, design: .default), alignment: .leading)
                    }
                }
                
                Spacer()
                
                Menu {
                    
                } label: {
                    Image(.icFilter)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 54)
                }
            }
            .padding(.horizontal, 17)
        }
        .padding(.top, 10)
    }
    
    private var mediaItemListSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 30) {
                    ForEach(viewModel.similarMediaCategory.arrSimilarMedias) { similarMedia in
                        similarMediaCell(
                            similarMedia: similarMedia
                        )
                    }
                }
                .padding(.vertical, 15)
            }
        }
        .padding(.top, 10)
    }
    
    private var deleteButton: some View {
        VStack(alignment: .center, spacing: 20) {
            let size = Utility.getSizeOfMedia(items: viewModel.arrSelectedItems)
            let count = "\(viewModel.arrSelectedItems.count) Items"
            
            CNDeleteMediaButton(title: "Delete Selected", message: "\(count) • \(size)", onTap: viewModel.btnDeleteAction)
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 24)
    }
}

extension SimilarMediaListView {
    
    @ViewBuilder
    func similarMediaCell(similarMedia: SimilarMedia) -> some View {
        let totalHorizontalPadding: CGFloat = 17 * 2
        let itemSpacing: CGFloat = 10
        let numberOfColumns: CGFloat = 2
        let availableWidth = UIScreen.main.bounds.width - totalHorizontalPadding - (itemSpacing * (numberOfColumns - 1))
        let itemWidth = availableWidth / numberOfColumns
        let columns = [
            GridItem(.fixed(itemWidth), spacing: itemSpacing),
            GridItem(.fixed(itemWidth), spacing: itemSpacing)
        ]
        
        
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .center, spacing: 0) {
                if let date = similarMedia.arrMediaItems.first?.formattedDate {
                    CNText(title: date, color: .white, font: .system(size: 18, weight: .semibold, design: .default), alignment: .leading)
                        .padding(.trailing, 5)
                }
                
                CNText(title: "• \(similarMedia.count) Items", color: .textGray, font: .system(size: 18, weight: .semibold, design: .default), alignment: .leading)
                    .padding(.trailing, 2)
                
                CNText(title: "(\(similarMedia.formattedSize))", color: .textGray, font: .system(size: 12, weight: .medium, design: .default), alignment: .leading)
                
                Spacer()
                
                CNText(title: "Deselect All", color: .textGray, font: .system(size: 17, weight: .regular, design: .default), alignment: .leading)
                    .onTapGesture {
                        viewModel.btnDeselectAllItems(similar: similarMedia)
                    }
            }
            .padding(.horizontal, 17)
            
            LazyVGrid(columns: columns, spacing: itemSpacing) {
                
                ForEach(similarMedia.arrMediaItems.indices, id: \.self) { index in
                    
                    let mediaItem = similarMedia.arrMediaItems[index]
                    
                    mediaItemCard(
                        mediaItem: mediaItem,
                        isBest: mediaItem.assetId == similarMedia.bestMediaAssetId,
                        isSelected: viewModel.arrSelectedItems.contains { $0.assetId == mediaItem.assetId },
                        size: itemWidth,
                        onTap: {
                            viewModel.openMediaPreview(media: mediaItem, similarMedia: similarMedia)
                        }
                    )
                }
            }
            .padding(.horizontal, 17)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func mediaItemCard(mediaItem: MediaItem, isBest: Bool, isSelected: Bool, size: CGFloat, onTap: @escaping (() -> Void)) -> some View {
        let width = size
        let height = size
        
        ZStack {
            CNMediaThumbImage(
                mediaItem: mediaItem,
                size: CGSize(width: width, height: height)
            )
            .clipped()
            .aspectRatio(1, contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            
            VStack(alignment: .trailing, spacing: 0) {
                if isBest {
                    HStack(alignment: .center, spacing: 0) {
                        HStack(alignment: .center, spacing: 3) {
                            Image(.icSparkle)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 10, height: 10)
                            
                            CNText(title: "BEST", color: .black, font: .system(size: 12, weight: .semibold, design: .default), alignment: .center)
                        }
                        .padding(.vertical, 3)
                        .padding(.horizontal, 7)
                        .background(Color(hex: "FEB400"))
                        .clipShape(Capsule())
                        .padding(11)
                        .frame(alignment: .leading)
                        Spacer()
                    }
                }
                
                Spacer()
                
                HStack(alignment: .center, spacing: 0) {
                    Spacer()
                    
                    Button {
                        viewModel.btnSelectItem(media: mediaItem)
                    } label: {
                        Image(isSelected ? .icSquareChecked : .icSquareUnchecked)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                    }
                    .padding(.trailing, 8)
                    .padding(.bottom, 8)
                }
            }
        }
        .frame(width: size, height: size)
        .onTapGesture(perform: onTap)
    }
}
