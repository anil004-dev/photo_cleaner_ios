//
//  HomeView.swift
//  CleanerApp
//
//  Created by iMac on 03/12/25.
//

import SwiftUI
import Kingfisher
import SDWebImageSwiftUI

struct HomeView: View {
    
    @EnvironmentObject var mediaDatabase: MediaDatabase
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        ZStack {
            Color.bgDarkBlue.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                homeSection
            }
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .onAppear {
            viewModel.onAppear(mediaDatabase: mediaDatabase)
        }
    }
    
    private var homeSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 0) {
                    storageSection
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var storageSection: some View {
        VStack(alignment: .leading, spacing: 11) {
            CNText(title: "Cleanup Storage", color: .white, font: .system(size: 24, weight: .bold, design: .default), alignment: .leading)
            
            VStack(alignment: .center, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        Image(systemName: "externaldrive.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.white)
                            .frame(width: 39, height: 29)
                            .padding(.bottom, 20)
                        
                        CNText(title: "STORAGE USED", color: .white, font: .system(size: 15, weight: .bold, design: .default), alignment: .leading)
                            .padding(.bottom, 5)
                        
                        let totalStorage = mediaDatabase.totalStorage
                        let freeStorage = mediaDatabase.freeStorage

                        let usedStorage = totalStorage - freeStorage
                        let usedStoragePerc = Int((usedStorage / totalStorage) * 100)
                        
                        CNText(title: "\(mediaDatabase.formattedUsedStorage) of \(mediaDatabase.formattedTotalStorage)", color: .white, font: .system(size: 14, weight: .regular, design: .default), alignment: .leading)
                            .padding(.bottom, 20)
                        
                        HStack(alignment: .bottom, spacing: 20) {
                            CNText(title: "\(usedStoragePerc)%", color: .white, font: .system(size: 36, weight: .semibold, design: .default), alignment: .leading)
                            
                            CNText(title: "\(mediaDatabase.formattedFreeStorage) FREE", color: .white, font: .system(size: 12, weight: .regular, design: .default), alignment: .leading)
                        }
                    }
                    
                    VStack(spacing: 0) {
                        
                    }
                    .frame(width: 123, height: 123)
                }
                .padding(18)
            }
            .frame(maxWidth: .infinity)
            .background(Color(hex: "12131C"))
            .clipShape(RoundedRectangle(cornerRadius: 29))
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    
    
//    private var homeSection: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            if viewModel.mediaDatabase?.scanState == .scanning {
//                Label("Scanning..", systemImage: "progress.indicator")
//                    .padding(.vertical, 10)
//                    .padding(.horizontal, 10)
//            }
//            
//            ScrollView(.vertical) {
//                if let mediaDatabase = viewModel.mediaDatabase {
//                    LazyVStack(alignment: .leading, spacing: 20) {
//                        
//                        MediaCategoryCell(
//                            category: mediaDatabase.photos,
//                            onTap: {
//                                viewModel.btnCategoryAction(category: mediaDatabase.photos)
//                            }
//                        )
//                        
//                        MediaCategoryCell(
//                            category: mediaDatabase.screenshots,
//                            onTap: {
//                                viewModel.btnCategoryAction(category: mediaDatabase.screenshots)
//                            }
//                        )
//                        
//                        MediaCategoryCell(
//                            category: mediaDatabase.livePhotos,
//                            onTap: {
//                                viewModel.btnCategoryAction(category: mediaDatabase.livePhotos)
//                            }
//                        )
//                        
//                        MediaCategoryCell(
//                            category: mediaDatabase.videos,
//                            onTap: {
//                                viewModel.btnCategoryAction(category: mediaDatabase.videos)
//                            }
//                        )
//                        
//                        MediaCategoryCell(
//                            category: mediaDatabase.screenRecordings,
//                            onTap: {
//                                viewModel.btnCategoryAction(category: mediaDatabase.screenRecordings)
//                            }
//                        )
//                        
//                        MediaCategoryCell(
//                            category: mediaDatabase.largeVideos,
//                            onTap: {
//                                viewModel.btnCategoryAction(category: mediaDatabase.largeVideos)
//                            }
//                        )
//                        
//                        SimilarCategoryCell(
//                            category: mediaDatabase.similarPhotos,
//                            onTap: {
//                                viewModel.btnSimilarMediaAction(category: mediaDatabase.similarPhotos)
//                            }
//                        )
//                        
//                        SimilarCategoryCell(
//                            category: mediaDatabase.similarScreenshots,
//                            onTap: {
//                                viewModel.btnSimilarMediaAction(category: mediaDatabase.similarScreenshots)
//                            }
//                        )
//                        
//                        SimilarCategoryCell(
//                            category: mediaDatabase.duplicatePhotos,
//                            onTap: {
//                                viewModel.btnSimilarMediaAction(category: mediaDatabase.duplicatePhotos)
//                            }
//                        )
//                        
//                        SimilarCategoryCell(
//                            category: mediaDatabase.duplicateScreenshots,
//                            onTap: {
//                                viewModel.btnSimilarMediaAction(category: mediaDatabase.duplicateScreenshots)
//                            }
//                        )
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.bottom, 20)
//                }
//            }
//        }
//    }
}
