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
            Color.cnThemeBg.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                mediaItemsSection
            }
        }
        .navigationTitle(viewModel.mediaCategory.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
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
                CNNavButton(
                    imageName: "line.3.horizontal.decrease",
                    fontWeight: .bold,
                    iconColor: .white,
                    iconSize: CGSize(width: 25, height: 25),
                    backgroundColor: .clear,
                    isLeftButton: false
                )
            }
        }
        .onAppear {
            viewModel.onAppear(mediaDatabase: mediaDatabase)
        }
        .sheet(isPresented: $viewModel.showLivePhotoPreviewView.sheet) {
            CNLivePhotoImagePreviewView(
                arrImageURLs: viewModel.showLivePhotoPreviewView.arrImageURLs,
                selectedImageURL: viewModel.showLivePhotoPreviewView.arrImageURLs.first!,
                onConvertAction: { imageURL in
                    viewModel.btnConvertStill(imageURL: imageURL)
                }
            )
        }
    }
    
    private var mediaItemsSection: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 15) {
                titleSection
                mediaItemListSection
                
                if !viewModel.arrSelectedItems.isEmpty {
                    deleteButton
                }
            }
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                VStack(alignment: .leading, spacing: 5) {
                    CNText(title: viewModel.mediaCategory.title, color: .white, font: .system(size: 16, weight: .semibold, design: .default), alignment: .leading)
                    
                    CNText(title: Utility.formattedSize(byte: viewModel.mediaCategory.totalSize), color: .white.opacity(0.8), font: .system(size: 12, weight: .medium, design: .default), alignment: .leading)
                }
                
                Spacer()
                
                Button(viewModel.arrSelectedItems.isEmpty ?  "Select All" : "Deselect All") {
                    viewModel.btnSelectAllAction()
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var mediaItemListSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.vertical) {
                if viewModel.mediaCategory.type == .videos || viewModel.mediaCategory.type == .largeVideos || viewModel.mediaCategory.type == .screenRecordings {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 20)
                        ],
                        spacing: 20
                    ) {
                        ForEach(viewModel.arrItems) { mediaItem in
                            mediaItemVideoCell(
                                mediaItem: mediaItem,
                                isSelected: viewModel.arrSelectedItems.contains { $0.assetId == mediaItem.assetId },
                                onTap: {
                                    viewModel.openMediaPreview(media: mediaItem)
                                }, onSelect: {
                                    viewModel.selectItem(media: mediaItem)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                } else {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 20),
                            GridItem(.flexible(), spacing: 20)
                        ],
                        spacing: 20
                    ) {
                        ForEach(viewModel.arrItems) { mediaItem in
                            
                            mediaItemCell(
                                mediaItem: mediaItem,
                                isSelected: viewModel.arrSelectedItems.contains { $0.assetId == mediaItem.assetId },
                                onTap: {
                                    viewModel.openMediaPreview(media: mediaItem)
                                }, onSelect: {
                                    viewModel.selectItem(media: mediaItem)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    private var deleteButton: some View {
        VStack(alignment: .center, spacing: 20) {
            CNText(title: Utility.getSizeOfMedia(items: viewModel.arrSelectedItems), color: .black, font: .system(size: 12, weight: .regular, design: .default))
            
            CNButton(title: "Delete (\(viewModel.arrSelectedItems.count))") {
                viewModel.btnDeleteAction()
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 15)
    }
}

extension MediaItemsListView {
    
    @ViewBuilder
    private func mediaItemCell(mediaItem: MediaItem, isSelected: Bool, onTap: @escaping (() -> Void), onSelect: @escaping (() -> Void)) -> some View {
        
        VStack(alignment: .trailing, spacing: 0) {
            ZStack {
                let width = ((UIScreen.main.bounds.width - 20 * 3) / 2)
                let size = CGSize(width: width, height: 200)
                
                ZStack {
                    CNMediaThumbImage(
                        mediaItem: mediaItem,
                        size: size
                    )
                    .clipped()
                    .allowsTightening(false)
                }
                .zIndex(400)
                .contentShape(Rectangle())
                .onTapGesture {
                    onTap()
                }
                
                VStack(alignment: .center, spacing: 0) {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(isSelected ? .blue : .white)
                            .frame(width: 20, height: 20)
                            .contentShape(Rectangle())
                            .padding(.bottom, 15)
                        
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .allowsHitTesting(true)
                    .onTapGesture {
                        onSelect()
                    }
                }
                .zIndex(500)
                
                if mediaItem.type == .livePhotos {
                    VStack(alignment: .trailing, spacing: 0) {
                        HStack(alignment: .top, spacing: 0) {
                            Spacer()
                            
                            Button {
                                viewModel.btnConvertToStillAction(mediaItem: mediaItem)
                            } label: {
                                CNText(title: "Convert to Still", color: .white, font: .system(size: 10, weight: .semibold, design: .default), alignment: .center)
                                    .padding(5)
                                    .background(Color.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 3))
                            }
                            .padding(15)
                        }
                        
                        Spacer()
                    }
                    .zIndex(600)
                }
            }
        }
        .id(mediaItem.id)
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    @ViewBuilder
    private func mediaItemVideoCell(mediaItem: MediaItem, isSelected: Bool, onTap: @escaping (() -> Void), onSelect: @escaping (() -> Void)) -> some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(alignment: .center, spacing: 20) {
                let width = ((UIScreen.main.bounds.width - 20 * 2) - 30) * 0.5
                
                CNMediaThumbImage(
                    mediaItem: mediaItem,
                    size: CGSize(width: width, height: 200)
                )
                .cornerRadius(10)
                .onTapGesture {
                    onTap()
                }
                
                Spacer(minLength: 0)
                
                VStack(alignment: .trailing, spacing: 0) {
                    HStack {
                        Spacer()
                        Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(isSelected ? .blue : .white)
                            .frame(width: 20, height: 20)
                            .contentShape(Rectangle())
                            .zIndex(1)
                            .allowsHitTesting(true)
                            .padding(.bottom, 15)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onSelect()
                    }
                    
                    Spacer()
                    
                    HStack(alignment: .center, spacing: 0) {
                         HStack(alignment: .center, spacing: 10) {
                             VStack(alignment: .leading, spacing: 5) {
                                 CNText(title: Utility.formattedSize(byte: mediaItem.fileSize), color: .white, font: .system(size: 13, weight: .medium, design: .default), alignment: .leading)
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
                     }
                    
                    Spacer()
                }
            }
            .padding(15)
        }
        .frame(height: 230)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.darkBlueCellBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            onTap()
        }
    }
}
