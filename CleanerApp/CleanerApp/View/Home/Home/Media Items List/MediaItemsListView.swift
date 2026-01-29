//
//  MediaItemsListView.swift
//  CleanerApp
//
//  Created by iMac on 03/12/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct MediaItemsListView: View {
    
    @EnvironmentObject var mediaDatabase: MediaDatabase
    @ObservedObject var viewModel: MediaItemsListViewModel
    
    var body: some View {
        ZStack {
            Color.bgDarkBlue.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                mediaItemsSection
            }
        }
        .toolbar(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.btnSelectAllAction()
                } label: {
                    HStack(alignment: .center, spacing: 5) {
                        Image(.icSqaureCheckmark)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                        
                        Button(viewModel.arrSelectedItems.count != viewModel.arrItems.count ?  "Select All" : "Deselect All") {
                            viewModel.btnSelectAllAction()
                        }
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
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                titleSection
                mediaItemListSection
            }
            
            if !viewModel.arrSelectedItems.isEmpty {
                deleteButton
            }
        }
        .animation(.easeInOut, value: viewModel.arrSelectedItems.isEmpty)
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    CNText(title: viewModel.mediaCategory.title, color: .white, font: .system(size: 36, weight: .bold, design: .default), alignment: .leading)
                    
                    HStack(alignment: .top, spacing: 5) {
                        CNText(title: viewModel.mediaCategory.formattedSize, color: .white, font: .system(size: 12, weight: .semibold, design: .default), alignment: .leading)
                        
                        CNText(title: "(\(viewModel.mediaCategory.count) Photos)", color: .textGray, font: .system(size: 12, weight: .semibold, design: .default), alignment: .leading)
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
    
    private var mediaItemListSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            let type = viewModel.mediaCategory.type
            let totalHorizontalPadding: CGFloat = 17 * 2
            let itemSpacing: CGFloat = type == .screenshots ? 5 : 10
            let numberOfColumns: CGFloat = type == .screenshots ? 3 : 2
            let availableWidth = UIScreen.main.bounds.width - totalHorizontalPadding - (itemSpacing * (numberOfColumns - 1))
            let itemWidth = availableWidth / numberOfColumns
            let itemHeight = type == .screenshots ? itemWidth * 1.8 : (type == .videos || type == .largeVideos || type == .screenRecordings) ? itemWidth * 1.5 : itemWidth
            let columns = Array(
                repeating: GridItem(.fixed(itemWidth), spacing: itemSpacing),
                count: Int(numberOfColumns)
            )
            
            ScrollView(.vertical) {
                LazyVGrid(columns: columns, spacing: itemSpacing) {
                    ForEach(viewModel.arrItems) { mediaItem in
                        mediaItemCard(
                            mediaItem: mediaItem,
                            isSelected: viewModel.arrSelectedItems.contains { $0.assetId == mediaItem.assetId },
                            width: itemWidth,
                            height: itemHeight,
                            onTap: {
                                viewModel.openMediaPreview(media: mediaItem)
                            }
                        )
                    }
                }
                .padding(.horizontal, 17)
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
            
            CNDeleteMediaButton(title: "Delete Selected", message: "\(count) • \(size)", onTap: viewModel.btnDeleteAction)
        }
        .padding(.horizontal, 10)
        .transition(.move(edge: .bottom))
        .animation(.easeInOut, value: viewModel.arrSelectedItems)
    }
}

extension MediaItemsListView {
    
    @ViewBuilder
    private func mediaItemCard(mediaItem: MediaItem, isSelected: Bool, width: CGFloat, height: CGFloat, onTap: @escaping (() -> Void)) -> some View {
        let width = width
        let height = height
        
        ZStack {
            CNMediaThumbImage(
                mediaItem: mediaItem,
                size: CGSize(width: width, height: height)
            )
            .clipped()
            .aspectRatio(1, contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            
            VStack(alignment: .trailing, spacing: 0) {
                if mediaItem.type == .livePhotos {
                    HStack(alignment: .center, spacing: 0) {
                        CNText(title: "CONVERT TO STILL", color: .white, font: .system(size: 11, weight: .bold, design: .default), alignment: .leading)
                            .padding(6)
                            .background(Color.btnBlue)
                            .onTapGesture {
                                viewModel.btnConvertToStillAction(mediaItem: mediaItem)
                            }
                        
                        Spacer()
                    }
                    .padding(11)
                }
                
                Spacer()
                
                ZStack {
                    if (mediaItem.type == .videos || mediaItem.type == .largeVideos || mediaItem.type == .screenRecordings) {
                        VStack(alignment: .center, spacing: 0) {
                            Spacer()
                            
                            Image(.imgVideoShadow)
                                .resizable()
                                .scaledToFill()
                                .frame(width: width, height: 56)
                        }
                    }
                    
                    VStack(alignment: .center, spacing: 0) {
                        Spacer()
                        
                        HStack(alignment: .center, spacing: 5) {
                            if (mediaItem.type == .videos || mediaItem.type == .largeVideos || mediaItem.type == .screenRecordings) {
                                CNText(title: Utility.formattedSize(byte: mediaItem.fileSize), color: .white, font: .system(size: 29, weight: .bold, design: .default), alignment: .leading, minimumScale: 0.5)
                            }
                            
                            Spacer(minLength: 0)
                            
                            Button {
                                viewModel.selectItem(media: mediaItem)
                            } label: {
                                Image(isSelected ? .icSquareChecked : .icSquareUnchecked)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 26, height: 26)
                                    .clipShape(Rectangle())
                            }
                            .frame(width: 26, height: 26)
                            .clipShape(Rectangle())
                        }
                        .padding(.horizontal, 13)
                        .padding(.vertical, 13)
                    }
                }
            }
        }
        .frame(width: width, height: height)
        .onTapGesture(perform: onTap)
    }
}
