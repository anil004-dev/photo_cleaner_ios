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
            Color.cnThemeBg.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                mediaItemsSection
            }
        }
        .navigationTitle(viewModel.similarMediaCategory.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            viewModel.onAppear(mediaDatabase: mediaDatabase)
        }
    }
    
    private var mediaItemsSection: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 15) {
                titleSection
                mediaItemListSection
                deleteButton
            }
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                VStack(alignment: .leading, spacing: 5) {
                    CNText(title: viewModel.similarMediaCategory.title, color: .white, font: .system(size: 16, weight: .semibold, design: .default), alignment: .leading)
                    
                    CNText(title: Utility.formattedSize(byte: viewModel.similarMediaCategory.totalSize) + " (\(viewModel.similarMediaCategory.totalMediaCount))", color: .white.opacity(0.8), font: .system(size: 12, weight: .medium, design: .default), alignment: .leading)
                }
                
                Spacer()
                
                Button("Select All") {
                    viewModel.btnSelectAllAction()
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var mediaItemListSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(viewModel.similarMediaCategory.arrSimilarMedias) { similarMedia in
                        similarMediaCell(
                            similarMedia: similarMedia
                        )
                    }
                }
            }
        }
    }
    
    private var deleteButton: some View {
        VStack(alignment: .center, spacing: 20) {
            CNText(title: Utility.getSizeOfMedia(items: viewModel.arrSelectedItems), color: .black, font: .system(size: 12, weight: .regular, design: .default))
            
            CNButton(title: "Delete") {
                viewModel.btnDeleteAction()
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 15)
    }
}

extension SimilarMediaListView {
    
    @ViewBuilder
    func similarMediaCell(similarMedia: SimilarMedia) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .center, spacing: 0) {
                CNText(
                    title: "\(similarMedia.arrMediaItems.count) similar items",
                    color: .white,
                    font: .system(size: 15, weight: .medium),
                    alignment: .leading
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 0)
                
                Button("Select All") {
                    viewModel.btnAllSelectItem(similar: similarMedia)
                }
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal) {
                HStack(alignment: .center, spacing: 15) {
                    ForEach(Array(similarMedia.arrMediaItems.enumerated()), id: \.offset) { index, mediaItem in
                        let isSelected = viewModel.arrSelectedItems.contains { $0.assetId == mediaItem.assetId }

                        ZStack {
                            CNMediaThumbImage(
                                mediaItem: mediaItem,
                                size: CGSize(width: 150, height: 150)
                            )
                            .clipped()
                            .aspectRatio(1, contentMode: .fill)

                            VStack {
                                Spacer()
                                HStack {
                                    if index == 0 {
                                        HStack(alignment: .center, spacing: 10) {
                                            CNText(title: "Best", color: .black, font: .system(size: 10, weight: .medium, design: .default))
                                                .padding(2)
                                        }
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                    }
                                    
                                    Spacer()
                                    
                                    Button {
                                        viewModel.btnSelectItem(media: mediaItem)
                                    } label: {
                                        Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundStyle(isSelected ? .blue : .white)
                                            .frame(width: 20, height: 20)
                                    }
                                }
                            }
                            .padding(5)
                        }
                        .frame(width: 150, height: 150)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
