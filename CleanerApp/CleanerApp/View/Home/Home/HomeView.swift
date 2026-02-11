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
            LinearGradient.orangeBg.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                homeSection
            }
        }
        .onAppear {
            viewModel.onAppear(mediaDatabase: mediaDatabase)
        }
    }
    
    private var homeSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            if viewModel.showPermissionSection {
                permissionSection
            } else {
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 20) {
                        storageSection
                        mediaSection
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    private var titleSection: some View {
        HStack(alignment: .center, spacing: 0) {
            CNText(title: "Ocean Storage Cleaner", color: .textBlack, font: .system(size: 24, weight: .heavy, design: .default), alignment: .leading)
                .italic()
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var permissionSection: some View {
        VStack(alignment: .center, spacing: 0) {
            titleSection
                .padding(.top, 8)
            
            Spacer()
            
            CNText(title: "Allow Access to Photos", color: .txtBlack, font: .system(size: 24, weight: .bold, design: .default), alignment: .center)
                .padding(.bottom, 8)
            
            CNText(title: "This allows us to find duplicate photos\nand videos so you can safely free up\nstorage.", color: .txtBlack, font: .system(size: 17, weight: .regular, design: .default), alignment: .center)
                .padding(.bottom, 30)
            
            CNButton(title: "Go to Settings") {
                viewModel.btnGoToSettingsAction()
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }
    
    private var storageSection: some View {
        VStack(alignment: .leading, spacing: 11) {
            titleSection
            
            VStack(alignment: .center, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    let totalStorage = mediaDatabase.totalStorage
                    let freeStorage = mediaDatabase.freeStorage
                    
                    let usedStorage = totalStorage - freeStorage
                    let usedStoragePerc = Int((usedStorage / totalStorage) * 100)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Image(systemName: "externaldrive.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.white)
                            .frame(width: 39, height: 29)
                            .padding(.bottom, 20)
                        
                        CNText(title: "STORAGE USED", color: .txtBlack, font: .system(size: 15, weight: .bold, design: .default), alignment: .leading)
                            .padding(.bottom, 5)
                        
                        CNText(title: "\(mediaDatabase.formattedUsedStorage) of \(mediaDatabase.formattedTotalStorage)", color: .txtBlack, font: .system(size: 14, weight: .regular, design: .default), alignment: .leading)
                            .padding(.bottom, 20)
                        
                        HStack(alignment: .bottom, spacing: 10) {
                            CNText(title: "\(usedStoragePerc)%", color: .txtBlack, font: .system(size: 36, weight: .heavy, design: .default), alignment: .leading)
                            
                            CNText(title: "\(mediaDatabase.formattedFreeStorage) FREE", color: .txtBlack, font: .system(size: 12, weight: .regular, design: .default), alignment: .leading)
                                .padding(.bottom, 6)
                        }
                        .frame(alignment: .bottom)
                    }
                    
                    Spacer(minLength: 0)
                    
                    ZStack {
                        CNGradientCircularProgressView(progress: Double(usedStorage / totalStorage), lineWidth: 18)
                        
                        Image(.icDb)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 92, height: 92)
                    }
                    .frame(width: 120, height: 120)
                    .padding(.trailing, 5)
                }
                .padding(18)
            }
            .frame(height: 170)
            .frame(maxWidth: .infinity)
            .background(LinearGradient.orangeBgHorizontal)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.primOrange, lineWidth: 2)
            )
            .background {
                RoundedRectangle(cornerRadius: 19)
                    .fill(Color.primOrange)
                    .offset(x: 4, y: 4)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    
    private var mediaSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            if viewModel.mediaDatabase?.scanState == .scanning {
                HStack {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.txtBlack)
                        .foregroundStyle(Color.txtBlack)
                        .frame(width: 18, height: 18)
                    
                    CNText(title: "Scanning", color: .txtBlack, font: .system(size: 17.0, weight: .semibold))
                }
                //Label("Scanning..", systemImage: "progress.indicator")
                    .padding(.vertical, 10)
                    .padding(.horizontal, 18)
            }
            
            ScrollView(.vertical) {
                if let mediaDatabase = viewModel.mediaDatabase {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        SimilarCategoryCell(
                            category: mediaDatabase.duplicatePhotos,
                            onTap: {
                                viewModel.btnSimilarMediaAction(category: mediaDatabase.duplicatePhotos)
                            }
                        )
                        
                        SimilarCategoryCell(
                            category: mediaDatabase.similarPhotos,
                            onTap: {
                                viewModel.btnSimilarMediaAction(category: mediaDatabase.similarPhotos)
                            }
                        )
                        
                        SimilarCategoryCell(
                            category: mediaDatabase.duplicateScreenshots,
                            onTap: {
                                viewModel.btnSimilarMediaAction(category: mediaDatabase.duplicateScreenshots)
                            }
                        )
                        
                        SimilarCategoryCell(
                            category: mediaDatabase.similarScreenshots,
                            onTap: {
                                viewModel.btnSimilarMediaAction(category: mediaDatabase.similarScreenshots)
                            }
                        )
                        
                        MediaCategoryCell(
                            category: mediaDatabase.photos,
                            onTap: {
                                viewModel.btnCategoryAction(category: mediaDatabase.photos)
                            }
                        )
                        
                        MediaCategoryCell(
                            category: mediaDatabase.screenshots,
                            onTap: {
                                viewModel.btnCategoryAction(category: mediaDatabase.screenshots)
                            }
                        )
                        
                        MediaCategoryCell(
                            category: mediaDatabase.livePhotos,
                            onTap: {
                                viewModel.btnCategoryAction(category: mediaDatabase.livePhotos)
                            }
                        )
                        
                        MediaCategoryCell(
                            category: mediaDatabase.videos,
                            onTap: {
                                viewModel.btnCategoryAction(category: mediaDatabase.videos)
                            }
                        )
                        
                        MediaCategoryCell(
                            category: mediaDatabase.screenRecordings,
                            onTap: {
                                viewModel.btnCategoryAction(category: mediaDatabase.screenRecordings)
                            }
                        )
                        
                        MediaCategoryCell(
                            category: mediaDatabase.compressVideos,
                            onTap: {
                                viewModel.btnCompressVideoAction(category: mediaDatabase.compressVideos)
                            }
                        )
                    }
                    .padding(.bottom, 20)
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}
