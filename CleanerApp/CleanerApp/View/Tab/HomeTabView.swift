//
//  HomeTabView.swift
//  CleanerApp
//
//  Created by iMac on 03/12/25.
//

import SwiftUI

struct HomeTabView: View {
    let homeViewModel: HomeViewModel
    
    @StateObject var tabRouter: TabRouter = TabRouter.shared
    @EnvironmentObject var navigationManager: NavigationManager 
    
    var body: some View {
        TabView(selection: $tabRouter.selectedTab) {
            NavigationStack(path: $navigationManager.path) {
                HomeView(viewModel: homeViewModel)
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        NavigationRouter.destinationView(for: destination)
                    }
            }
            .tag(0)
            .tabItem {
                Label("Home", image: "ic_home")
            }
            
            NavigationStack(path: $navigationManager.path) {
                ContactHomeView()
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        NavigationRouter.destinationView(for: destination)
                    }
            }
            .tag(1)
            .tabItem {
                Label("Diary", image: "ic_diary")
            }
            
            NavigationStack(path: $navigationManager.path) {
                ChargingAnimationListView()
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        NavigationRouter.destinationView(for: destination)
                    }
            }
            .tag(2)
            .tabItem {
                Label("Animation", image: "ic_animation")
            }
            
            NavigationStack(path: $navigationManager.path) {
                SettingsView()
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        NavigationRouter.destinationView(for: destination)
                    }
            }
            .tag(3)
            .tabItem {
                Label("Settings", image: "ic_settings")
            }
            
        }
        .fullScreenCover(isPresented: $tabRouter.showVideoPlayerView.sheet) {
            if let player = tabRouter.showVideoPlayerView.player {
                CNAVPlayerView(player: player) {
                    tabRouter.showVideoPlayerView = (false, nil)
                }
                .presentationDetents([.large])
            }
        }
        .onAppear {
            let appearance = UITabBarAppearance()
            let itemAppearance = UITabBarItemAppearance()

            itemAppearance.normal.iconColor = UIColor(Color.txtBlack)
            itemAppearance.normal.titleTextAttributes = [
                .foregroundColor:  UIColor(Color.txtBlack)
            ]

            itemAppearance.selected.iconColor = UIColor(Color.primOrange)
            itemAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(Color.primOrange)
            ]

            appearance.configureWithOpaqueBackground()
            appearance.inlineLayoutAppearance = itemAppearance
            appearance.stackedLayoutAppearance = itemAppearance
            appearance.compactInlineLayoutAppearance = itemAppearance

            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
