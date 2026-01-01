//
//  CleanerAppApp.swift
//  CleanerApp
//
//  Created by iMac on 03/12/25.
//

import SwiftUI
import SDWebImage
import SDWebImagePhotosPlugin


@main
struct CleanerAppApp: App {
    
    @StateObject var appState: AppState = AppState.shared
    @StateObject var alertManager: CNAlertManager = CNAlertManager.shared
    @StateObject var mediaDatabase: MediaDatabase = MediaDatabase.shared
    
    init() {
        let photosLoader = SDImagePhotosLoader.shared
        SDImageLoadersManager.shared.addLoader(photosLoader)
        SDWebImageManager.defaultImageLoader = SDImageLoadersManager.shared
        
        SDImageCache.shared.config.shouldCacheImagesInMemory = false
        SDImageCache.shared.config.shouldUseWeakMemoryCache = true
        SDImageCache.shared.config.shouldRemoveExpiredDataWhenTerminate = true
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ZStack {
                    rootView(appFlow: appState.flow)
                }
            }
            .alert(
                alertManager.alertModel.title,
                isPresented: $alertManager.showAlert,
                actions: {
                    Button {
                        alertManager.alertModel.leftButtonAction?()
                    } label: {
                        Text(alertManager.alertModel.leftButtonTitle)
                    }
                    
                    if !alertManager.alertModel.rightButtonTitle.isEmpty {
                        Button {
                            alertManager.alertModel.rightButtonAction?()
                        } label: {
                            Text(alertManager.alertModel.rightButtonTitle)
                        }
                    }
                },
                message: {
                    Text(alertManager.alertModel.message)
                }
            )
            
        }
        .environmentObject(alertManager)
        .environmentObject(mediaDatabase)
    }
    
    @ViewBuilder
    private func rootView(appFlow: AppFlow) -> some View {
        switch appFlow {
        case .none:
            EmptyView()
        case .home:
            HomeTabView(homeViewModel: appState.homeViewModel)
        }
    }
}
