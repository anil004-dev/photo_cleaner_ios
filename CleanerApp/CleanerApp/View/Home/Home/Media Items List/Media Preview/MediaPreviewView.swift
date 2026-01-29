//
//  MediaPreviewView.swift
//  CleanerApp
//
//  Created by iMac on 05/12/25.
//

import SwiftUI

struct MediaPreviewView: View {
    @ObservedObject var viewModel: MediaPreviewViewModel
    
    var body: some View {
        ZStack {
            Color.bgDarkBlue.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                mediaPreviewSection
            }
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.btnDoneAction()
                } label: {
                    CNText(title: "Done", color: .white, font: .system(size: 16, weight: .semibold, design: .default))
                }
            }
        }
    }
    
    private var mediaPreviewSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            currentMediaPreviewSection
            mediaListSection
            deleteButton
        }
    }
    
    private var currentMediaPreviewSection: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading, spacing: 0) {
                let mediaItem = viewModel.arrItems[viewModel.currentIndex]
                let isSelected = viewModel.arrSelectedItems.contains { $0.assetId == mediaItem.assetId }
                
                ZStack(alignment: .bottom) {
                    CNMediaPreview(
                        mediaItem: mediaItem
                    )
                    .id(viewModel.currentIndex)
                    
                    HStack(alignment: .center, spacing: 0) {
                        if viewModel.mediaType == .largeVideos {
                            let estimatedSize = VideoCompressor.shared.estimatedSizeRange(mediaItem: mediaItem, quality: .medium)
                            let formattedSize = estimatedSize
                            
                            HStack(alignment: .center, spacing: 0) {
                                CNText(title: formattedSize, color: .white, font: .system(size: 10, weight: .semibold, design: .default), alignment: .center)
                                    .padding(5)
                            }
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                        }
                        
                        Spacer()
                        
                        if viewModel.mediaType == .largeVideos {
                            Button {
                                viewModel.btnCompressVideo(mediaItem: mediaItem)
                            } label: {
                                CNText(title: "Compress", color: .white, font: .system(size: 10, weight: .semibold, design: .default), alignment: .center)
                                    .padding(5)
                                    .background(Color.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 3))
                            }
                            .padding(.trailing, 10)
                        }
                        
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
                        .padding(.trailing, 10)
                        .padding(.bottom, 10)
                    }
                    .padding(15)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private var mediaListSection: some View {
        VStack(alignment: .leading, spacing: 0) {
                
            HStack(alignment: .center, spacing: 0) {
                Spacer(minLength: 0)
                CNText(title: "\(viewModel.currentIndex+1)/\(viewModel.arrItems.count)", color: .white, font: .system(size: 14, weight: .semibold, design: .default))
                Spacer(minLength: 0)
            }
            .padding(.vertical, 20)
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    LazyHStack(alignment: .center, spacing: 10) {
                        ForEach(0..<viewModel.arrItems.count, id: \.self) { index in
                            let mediaItem = viewModel.arrItems[index]
                            mediaRow(
                                mediaItem: mediaItem,
                                isSelected: viewModel.arrSelectedItems.contains { $0.assetId == mediaItem.assetId },
                                onTap: {
                                    viewModel.scrollToItem(media: mediaItem)
                                },
                                onSelect: {
                                    viewModel.selectItem(media: mediaItem)
                                }
                            )
                            .id(index)
                        }
                    }
                    .padding(.horizontal, 20)
                    .onChange(of: viewModel.currentIndex) { _, newValue in
                        withAnimation {
                            proxy.scrollTo(newValue, anchor: .center)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            .frame(height: 100)
        }
    }
    
    private var deleteButton: some View {
        VStack(alignment: .center, spacing: 20) {
            let size = Utility.getSizeOfMedia(items: viewModel.arrSelectedItems)
            let count = "\(viewModel.arrSelectedItems.count) Items"
            
            CNDeleteMediaButton(
                title: "Delete Selected", message: "\(count) • \(size)",
                onTap: {
                    NavigationManager.shared.pop()
                    viewModel.onDeleteBtnAction(viewModel.arrSelectedItems)
                }
            )
        }
        .padding(.horizontal, 10)
        .padding(.top, 15)
        .padding(.bottom, 24)
    }
}

extension MediaPreviewView {
    
    @ViewBuilder
    private func mediaRow(mediaItem: MediaItem, isSelected: Bool, onTap: @escaping (() -> Void), onSelect: @escaping (() -> Void)) -> some View {
        VStack(alignment: .center, spacing: 0) {
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    CNMediaThumbImage(
                        mediaItem: mediaItem,
                        size: CGSize(width: 100, height: 100)
                    )
                    .clipped()
                    .allowsTightening(false)
                }
                .zIndex(400)
                .contentShape(RoundedRectangle(cornerRadius: 12))
                .onTapGesture {
                    onTap()
                }
                
                Image(isSelected ? .icSquareChecked : .icSquareUnchecked)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                    .padding(5)
                    .clipShape(Rectangle())
                    .zIndex(500)
                    .onTapGesture {
                        onSelect()
                    }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
