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
            LinearGradient.orangeBg.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                mediaItemsSection
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                let allItems = viewModel.similarMediaCategory.arrSimilarMedias
                    .flatMap { media in
                        media.arrMediaItems.filter { $0.assetId != media.bestMediaAssetId }
                    }
                
                
                let isSelectedAll = allItems.allSatisfy { item in
                    viewModel.arrSelectedItems.contains { $0.assetId == item.assetId }
                }
                
                Button {
                    if isSelectedAll {
                        viewModel.btnDeselectAllAction()
                    } else {
                        viewModel.btnSelectAllAction()
                    }
                } label: {
                    HStack(alignment: .center, spacing: 10) {
                        Image(.icSqaureCheckmark)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color.txtBlack)
                            .frame(width: 18, height: 18)
                        
                        CNText(
                            title: isSelectedAll ? "Deselect All" : "Select All",
                            color: .txtBlack,
                            font: .system(size: 17, weight: .medium),
                            alignment: .center
                        )
                    }
                    .padding(.horizontal, 10)
                }
            }
            
            if #available(iOS 26.0, *) {
                ToolbarSpacer(.fixed, placement: .primaryAction)
            }
            
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    ForEach(MediaItemSortType.allCases, id: \.self) { sortType in
                        Button {
                            viewModel.sortType = sortType
                            viewModel.sortItems()
                        } label: {
                            HStack {
                                Text(sortType.rawValue)
                                
                                if viewModel.sortType == sortType {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Image(.icFilter)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                        .clipShape(Circle())
                }
            }
        }
        .onAppear {
            viewModel.onAppear(mediaDatabase: mediaDatabase)
        }
    }
    
    private var mediaItemsSection: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                titleSection
                
                if !viewModel.similarMediaCategory.arrSimilarMedias.isEmpty {
                    mediaItemListSection
                } else {
                    Spacer(minLength: 0)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !viewModel.arrSelectedItems.isEmpty {
                deleteButton
            }
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .animation(.easeInOut, value: viewModel.arrSelectedItems.isEmpty)
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    CNText(title: viewModel.similarMediaCategory.title, color: .txtBlack, font: .system(size: 34, weight: .bold, design: .default), alignment: .leading)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    CNText(title: viewModel.similarMediaCategory.formattedSize, color: .txtBlack, font: .system(size: 12, weight: .heavy, design: .default), alignment: .trailing)
                    
                    CNText(title: "\(viewModel.similarMediaCategory.totalMediaCount) Photos", color: Color(hex: "80818A"), font: .system(size: 12, weight: .semibold, design: .default), alignment: .trailing)
                }
            }
            .padding(.horizontal, 18)
        }
        .padding(.top, 10)
    }
    
    private var mediaItemListSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.similarMediaCategory.arrSimilarMedias) { similarMedia in
                        similarMediaCell(
                            similarMedia: similarMedia
                        )
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 15)
            }
        }
        .padding(.top, 10)
        .transition(.move(edge: .bottom))
    }
    
    private var deleteButton: some View {
        VStack(alignment: .center, spacing: 20) {
            let size = Utility.getSizeOfMedia(items: viewModel.arrSelectedItems)
            let count = "\(viewModel.arrSelectedItems.count) Items"
            
            CNDeleteMediaButton(title: "Delete Selected", message: "\(count) Items • \(size)", onTap: viewModel.btnDeleteAction)
        }
        .transition(.move(edge: .bottom))
        .animation(.easeInOut, value: viewModel.arrSelectedItems)
    }
}

extension SimilarMediaListView {
    
    @ViewBuilder
    func similarMediaCell(similarMedia: SimilarMedia) -> some View {
        let totalHorizontalPadding: CGFloat = 32 * 2
        let itemSpacing: CGFloat = 10
        let numberOfColumns: CGFloat = 2
        let availableWidth = UIScreen.main.bounds.width - totalHorizontalPadding - (itemSpacing * (numberOfColumns - 1))
        let itemWidth = availableWidth / numberOfColumns
        let columns = [
            GridItem(.fixed(itemWidth), spacing: itemSpacing),
            GridItem(.fixed(itemWidth), spacing: itemSpacing)
        ]
        
        VStack(alignment: .leading, spacing: 0) {
            CNText(title: "\(similarMedia.count) Photos - \(similarMedia.formattedSize)", color: .txtBlack, font: .system(size: 18, weight: .semibold, design: .default), alignment: .leading)
                .padding(12)
            
            LazyVGrid(columns: columns, spacing: itemSpacing) {
                
                ForEach(similarMedia.arrMediaItems, id: \.assetId) { mediaItem in
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
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
        .padding(1)
    }
    
    @ViewBuilder
    private func mediaItemCard(mediaItem: MediaItem, isBest: Bool, isSelected: Bool, size: CGFloat, onTap: @escaping (() -> Void)) -> some View {
        let width = size
        let height = size
        
        ZStack {
            VStack(alignment: .center, spacing: 0) {
                CNMediaThumbImage(
                    mediaItem: mediaItem,
                    size: CGSize(width: width, height: height)
                )
            }
            .background(Color.bgDarkBlue)
            .onTapGesture(perform: onTap)
            .clipShape(RoundedRectangle(cornerRadius: 18))
                
            VStack(alignment: .trailing, spacing: 0) {
                if isBest {
                    HStack(alignment: .center, spacing: 0) {
                        HStack(alignment: .center, spacing: 3) {
                            Image(.icSparkle)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(.white)
                                .frame(width: 10, height: 10)
                            
                            CNText(title: "BEST", color: .white, font: .system(size: 12, weight: .semibold, design: .default), alignment: .center)
                        }
                        .padding(.vertical, 3)
                        .padding(.horizontal, 7)
                        .background(Color.primOrange)
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
                        Image(isSelected ? .icSquareCheckedNew : .icSquareUncheckedNew)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 26, height: 26)
                    }
                    .frame(width: 26, height: 26)
                    .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 0)
                    .animation(.easeInOut(duration: 0.1), value: isSelected)
                    .padding(.trailing, 10)
                    .padding(.bottom, 10)
                }
            }
        }
        .frame(width: size, height: size)
    }
}
