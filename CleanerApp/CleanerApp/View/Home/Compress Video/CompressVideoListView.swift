//
//  CompressVideoListView.swift
//  CleanerApp
//
//  Created by iMac on 29/01/26.
//

import SwiftUI

struct CompressVideoListView: View {
    
    @EnvironmentObject var mediaDatabase: MediaDatabase
    @StateObject var viewModel = CompressVideoListViewModel()
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                compressVideoListSection
            }
        }
        .onAppear {
            viewModel.onAppear(mediaDatabase: mediaDatabase)
        }
    }
    
    private var compressVideoListSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let mediaDatabase = viewModel.mediaDatabase {
                titleSection(category: mediaDatabase.allVideos)
                    .onChange(of: mediaDatabase.videos) { oldValue, newValue in
                        viewModel.sortItems()
                    }
                    .onChange(of: mediaDatabase.screenshots) { oldValue, newValue in
                        viewModel.sortItems()
                    }
                
                videoListSection(category: mediaDatabase.allVideos)
            }
        }
    }
    
    private func titleSection(category: MediaCategoryModel) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    CNText(title: "Compress Video", color: .white, font: .system(size: 36, weight: .bold, design: .default), alignment: .leading)
                    
                    HStack(alignment: .top, spacing: 5) {
                        CNText(title: category.formattedSize, color: .white, font: .system(size: 12, weight: .semibold, design: .default), alignment: .leading)
                        
                        CNText(title: "(\(category.count) \(category.title))", color: .textGray, font: .system(size: 12, weight: .semibold, design: .default), alignment: .leading)
                    }
                }
                
                Spacer()
                
                Menu {
                    ForEach(MediaItemSortType.allCases, id: \.self) { sortType in
                        Button {
                            viewModel.selectSortType(type: sortType)
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
                        .frame(width: 45, height: 54)
                }
            }
            .padding(.horizontal, 17)
        }
        .padding(.top, 10)
    }
    
    private func videoListSection(category: MediaCategoryModel) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            let totalHorizontalPadding: CGFloat = 6 * 2
            let itemSpacing: CGFloat = 6
            let numberOfColumns: CGFloat = 2
            let availableWidth = UIScreen.main.bounds.width - totalHorizontalPadding - (itemSpacing * (numberOfColumns - 1))
            let itemWidth = availableWidth / numberOfColumns
            let itemHeight = itemWidth * 1.5
            let columns = Array(
                repeating: GridItem(.fixed(itemWidth), spacing: itemSpacing),
                count: Int(numberOfColumns)
            )
            
            ScrollView(.vertical) {
                LazyVGrid(columns: columns, spacing: itemSpacing) {
                    ForEach(viewModel.arrItems) { mediaItem in
                        mediaItemCard(
                            mediaItem: mediaItem,
                            width: itemWidth,
                            height: itemHeight,
                            onTap: {
                                viewModel.btnMediaAction(media: mediaItem)
                            }
                        )
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 15)
            }
        }
        .padding(.top, 10)
        .transition(.move(edge: .bottom))
    }
}

extension CompressVideoListView {
    
    @ViewBuilder
    private func mediaItemCard(mediaItem: MediaItem, width: CGFloat, height: CGFloat, onTap: @escaping (() -> Void)) -> some View {
        let width = width
        let height = height
        
        ZStack {
            VStack(alignment: .center, spacing: 0) {
                CNMediaThumbImage(
                    mediaItem: mediaItem,
                    size: CGSize(width: width, height: height)
                )
                .clipShape(RoundedRectangle(cornerRadius: 22))
            }
            .background(Color.bgDarkBlue)
            .onTapGesture(perform: onTap)
           
                
            let formattedSize = "200 MB"
                
            ZStack(alignment: .bottom) {
                VStack(alignment: .center, spacing: 0) {
                    Spacer()
                    
                    Image(.imgVideoShadow)
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: 56)
                }
                
                VStack(alignment: .center, spacing: 0) {
                    Spacer()
                    Button {
                        viewModel.btnCompressVideo(mediaItem: mediaItem)
                    } label: {
                        HStack(alignment: .center, spacing: 9) {
                            CNText(title: "Save \(formattedSize)", color: .white, font: .system(size: 14, weight: .bold, design: .default), alignment: .center)
                            
                            Image(.icChevronDouble)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14, height: 13)
                        }
                        .padding(10)
                        .background(Color.btnBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                    }
                    .padding(11)
                }
            }
        }
        .frame(width: width, height: height)
        .onTapGesture(perform: onTap)
    }
}

