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
            LinearGradient.orangeBg.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                compressVideoListSection
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            viewModel.update(from: mediaDatabase)
        }
        .toolbar {
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
        .onChange(of: mediaDatabase.compressVideos.items) { _, _ in
            viewModel.update(from: mediaDatabase)
        }
    }
    
    private var compressVideoListSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleSection(category: mediaDatabase.compressVideos)
            
            if !mediaDatabase.compressVideos.items.isEmpty {
                videoListSection(category: mediaDatabase.compressVideos)
            } else {
                Spacer(minLength: 0)
            }
        }
    }
    
    private func titleSection(category: MediaCategoryModel) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    CNText(title: category.title, color: .txtBlack, font: .system(size: 34, weight: .bold, design: .default), alignment: .leading)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    CNText(title: category.formattedSize, color: .txtBlack, font: .system(size: 12, weight: .heavy, design: .default), alignment: .trailing)
                    
                    CNText(title: "\(category.count) \(category.subType)", color: Color(hex: "80818A"), font: .system(size: 12, weight: .semibold, design: .default), alignment: .trailing)
                }
            }
            .padding(.horizontal, 18)
        }
        .padding(.top, 10)
    }
    
    private func videoListSection(category: MediaCategoryModel) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            let totalHorizontalPadding: CGFloat = (6 + 12) * 2
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
                LazyVStack(alignment: .leading, spacing: 0) {
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
                    .padding(12)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.primOrange, lineWidth: 2)
                )
                .background {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.primOrange)
                        .offset(x: 3.5, y: 3.5)
                }
                .padding(1)
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
                            .padding(11)
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
                            .background(Color.primOrange)
                            .clipShape(RoundedRectangle(cornerRadius: 9))
                        }
                        .padding(11)
                    }
                }
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 18))
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
