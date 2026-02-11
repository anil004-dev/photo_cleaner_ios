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
            LinearGradient.orangeBg.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                mediaItemsSection
            }
        }
        .toolbar(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.btnSelectAllAction()
                } label: {
                    HStack(alignment: .center, spacing: 10) {
                        Image(.icSqaureCheckmark)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color.textBlack)
                            .frame(width: 18, height: 18)
                        
                        Text(viewModel.arrSelectedItems.count != viewModel.arrItems.count ?  "Select All" : "Deselect All")
                            .foregroundStyle(.textBlack)
                    }
                    .padding(.horizontal, 10)
                    .clipShape(Rectangle())
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
                
                if !viewModel.arrItems.isEmpty {
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
                    CNText(title: viewModel.mediaCategory.title, color: .txtBlack, font: .system(size: 34, weight: .bold, design: .default), alignment: .leading)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    CNText(title: viewModel.mediaCategory.formattedSize, color: .txtBlack, font: .system(size: 12, weight: .heavy, design: .default), alignment: .trailing)
                    
                    CNText(title: "\(viewModel.mediaCategory.count) \(viewModel.mediaCategory.subType)", color: Color(hex: "80818A"), font: .system(size: 12, weight: .semibold, design: .default), alignment: .trailing)
                }
            }
            .padding(.horizontal, 18)
        }
        .padding(.top, 10)
    }
    
    private var mediaItemListSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            let type = viewModel.mediaCategory.type
            let isVideo = (type == .videos || type == .largeVideos || type == .screenRecordings)
            let totalHorizontalPadding: CGFloat = ((isVideo ? 6 : 17) + 12) * 2
            let itemSpacing: CGFloat = type == .screenshots ? 11 : (isVideo ? 6 : 10)
            let numberOfColumns: CGFloat = type == .screenshots ? 3 : 2
            let availableWidth = UIScreen.main.bounds.width - totalHorizontalPadding - (itemSpacing * (numberOfColumns - 1))
            let itemWidth = availableWidth / numberOfColumns
            let itemHeight = type == .screenshots ? itemWidth * 1.8 : (isVideo ? itemWidth * 1.5 : itemWidth)
            let columns = Array(
                repeating: GridItem(.fixed(itemWidth), spacing: itemSpacing),
                count: Int(numberOfColumns)
            )
            
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 0) {
                    LazyVGrid(columns: columns, spacing: itemSpacing) {
                        ForEach(viewModel.arrItems) { mediaItem in
                            mediaItemCard(
                                mediaItem: mediaItem,
                                isSelected: viewModel.arrSelectedItems.contains { $0.assetId == mediaItem.assetId },
                                width: itemWidth,
                                height: itemHeight,
                                onTap: {
                                    viewModel.btnMediaAction(media: mediaItem)
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
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.primOrange)
                        .offset(x: 3.5, y: 3.5)
                }
                .padding(1)
                .padding(.horizontal, isVideo ? 6 : 17)
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

extension MediaItemsListView {
    
    @ViewBuilder
    private func mediaItemCard(mediaItem: MediaItem, isSelected: Bool, width: CGFloat, height: CGFloat, onTap: @escaping (() -> Void)) -> some View {
        let width = width
        let height = height
        
        ZStack {
            VStack(alignment: .center, spacing: 0) {
                CNMediaThumbImage(
                    mediaItem: mediaItem,
                    size: CGSize(width: width, height: height)
                )
                
            }
            .background(Color.bgDarkBlue)
            .onTapGesture(perform: onTap)
            
            VStack(alignment: .trailing, spacing: 0) {
                if mediaItem.type == .livePhotos {
                    HStack(alignment: .center, spacing: 0) {
                        CNText(title: "CONVERT TO STILL", color: .white, font: .system(size: 11, weight: .bold, design: .default), alignment: .leading)
                            .padding(6)
                            .background(Color.primOrange)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
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
                                Image(isSelected ? .icSquareCheckedNew : .icSquareUncheckedNew)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 26, height: 26)
                                    .clipShape(Rectangle())
                            }
                            .frame(width: 26, height: 26)
                            .clipShape(Rectangle())
                            .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 0)
                            .animation(.easeInOut(duration: 0.1), value: isSelected)
                        }
                        .padding(.horizontal, 13)
                        .padding(.vertical, 13)
                    }
                }
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .onTapGesture(perform: onTap)
    }
}

