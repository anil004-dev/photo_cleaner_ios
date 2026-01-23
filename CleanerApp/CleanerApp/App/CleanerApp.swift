//
//  CleanerApp.swift
//  CleanerApp
//
//  Created by iMac on 03/12/25.
//

import SwiftUI
import SDWebImage
import SDWebImagePhotosPlugin


@main
struct CleanerApp: App {
    
    @StateObject var appState: AppState = AppState.shared
    @StateObject var alertManager: CNAlertManager = CNAlertManager.shared
    @StateObject var mediaDatabase: MediaDatabase = MediaDatabase.shared
    @StateObject var navigationManager: NavigationManager = NavigationManager.shared
    
    init() {
        _ = BatteryMonitor.shared
        
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
                        .transition(.opacity)
                }
                .animation(.easeInOut(duration: 0.35), value: appState.flow)
                .fullScreenCover(isPresented: $appState.showChargingAnimation) {
                    if let animationType = UserDefaultManager.selectedChargingAnimation {
                        ChargingAnimationView(animationType: animationType)
                    }
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
            .onAppear {
                WidgetDataProvider.shared.updateAll()
            }
        }
        .environmentObject(alertManager)
        .environmentObject(navigationManager)
        .environmentObject(mediaDatabase)
    }
    
    @ViewBuilder
    private func rootView(appFlow: AppFlow) -> some View {
        switch appFlow {
        case .none:
            EmptyView()
        case .welcome:
            NavigationStack(path: $navigationManager.path) {
                WelcomeView()
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        NavigationRouter.destinationView(for: destination)
                    }
            }
        case .onboarding:
            OnboardingView()
        case .home:
            HomeTabView(homeViewModel: appState.homeViewModel)
        }
    }
}
