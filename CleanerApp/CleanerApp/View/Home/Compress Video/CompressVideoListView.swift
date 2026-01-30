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
            viewModel.update(from: mediaDatabase)
        }
        .onChange(of: mediaDatabase.compressVideos.items) { _, _ in
            viewModel.update(from: mediaDatabase)
        }
    }
    
    private var compressVideoListSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleSection(category: mediaDatabase.compressVideos)
            videoListSection(category: mediaDatabase.compressVideos)
        }
    }
    
    private func titleSection(category: MediaCategoryModel) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    CNText(title: category.title, color: .white, font: .system(size: 36, weight: .bold, design: .default), alignment: .leading)
                    
                    HStack(alignment: .top, spacing: 5) {
                        CNText(title: category.formattedSize, color: .white, font: .system(size: 12, weight: .semibold, design: .default), alignment: .leading)
                        
                        CNText(title: "(\(category.count) Videos)", color: .textGray, font: .system(size: 12, weight: .semibold, design: .default), alignment: .leading)
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
                        MediaItemCardView(
                            mediaItem: mediaItem,
                            width: itemWidth,
                            height: itemHeight,
                            onTap: { compressInfo in
                                viewModel.btnMediaAction(media: mediaItem, compressInfo: compressInfo)
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


struct MediaItemCardView: View {
    @ObservedObject var mediaItem: MediaItem
    let width: CGFloat
    let height: CGFloat
    let onTap: (VideoCompressionInfo) -> Void
    
    var body: some View {
        mediaItemCard()
    }
    
    private func mediaItemCard() -> some View {
        ZStack {
            VStack(alignment: .center, spacing: 0) {
                CNMediaThumbImage(
                    mediaItem: mediaItem,
                    size: CGSize(width: width, height: height)
                )
                .clipShape(RoundedRectangle(cornerRadius: 22))
            }
            .background(Color.bgDarkBlue)
            
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
                    
                    if mediaItem.compressionInfo == nil {
                        ProgressView()
                    } else if let compressInfo = mediaItem.compressionInfo {
                        Button {
                            onTap(compressInfo)
                        } label: {
                            HStack(alignment: .center, spacing: 9) {
                                CNText(title: "Save \(compressInfo.formattedSavedSize)", color: .white, font: .system(size: 14, weight: .bold, design: .default), alignment: .center)
                                
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
        }
        .frame(width: width, height: height)
        .onAppear {
            calculateEstimateSize()
        }
        .onTapGesture {
            if let compressInfo = mediaItem.compressionInfo {
                onTap(compressInfo)
            }
        }
        .onChange(of: mediaItem.fileSize) { _, _ in
            calculateEstimateSize()
        }
    }
    
    private func calculateEstimateSize() {
        if mediaItem.fileSize != 0, mediaItem.compressionInfo == nil {
            Task {
                mediaItem.compressionInfo = await VideoCompressorManager.shared.estimateSize(media: mediaItem, quality: .low)
            }
        }
    }
}
