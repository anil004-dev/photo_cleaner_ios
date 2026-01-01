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
            //LinearGradient.blueBg.ignoresSafeArea()
            Color.cnThemeBg.ignoresSafeArea()
            
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
            if viewModel.mediaDatabase?.scanState == .scanning {
                Label("Scanning..", systemImage: "progress.indicator")
                    .padding(.vertical, 10)
                    .padding(.horizontal, 10)
            }
            
            ScrollView(.vertical) {
                if let mediaDatabase = viewModel.mediaDatabase {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        
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
                            category: mediaDatabase.largeVideos,
                            onTap: {
                                viewModel.btnCategoryAction(category: mediaDatabase.largeVideos)
                            }
                        )
                        
                        SimilarCategoryCell(
                            category: mediaDatabase.similarPhotos,
                            onTap: {
                                viewModel.btnSimilarMediaAction(category: mediaDatabase.similarPhotos)
                            }
                        )
                        
                        SimilarCategoryCell(
                            category: mediaDatabase.similarScreenshots,
                            onTap: {
                                viewModel.btnSimilarMediaAction(category: mediaDatabase.similarScreenshots)
                            }
                        )
                        
                        SimilarCategoryCell(
                            category: mediaDatabase.duplicatePhotos,
                            onTap: {
                                viewModel.btnSimilarMediaAction(category: mediaDatabase.duplicatePhotos)
                            }
                        )
                        
                        SimilarCategoryCell(
                            category: mediaDatabase.duplicateScreenshots,
                            onTap: {
                                viewModel.btnSimilarMediaAction(category: mediaDatabase.duplicateScreenshots)
                            }
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}
