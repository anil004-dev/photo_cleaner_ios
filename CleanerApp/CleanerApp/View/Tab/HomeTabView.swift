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
                Label("Clean", image: "ic_clean")
            }
            
            NavigationStack(path: $navigationManager.path) {
                ContactHomeView()
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        NavigationRouter.destinationView(for: destination)
                    }
            }
            .tag(1)
            .tabItem {
                Label("Contacts", image: "ic_contact")
            }
            
            NavigationStack(path: $navigationManager.path) {
                CompressVideoListView()
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        NavigationRouter.destinationView(for: destination)
                    }
            }
            .tag(2)
            .tabItem {
                Label("Compress", image: "ic_compress")
            }
            
            NavigationStack(path: $navigationManager.path) {
                ChargingAnimationListView()
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        NavigationRouter.destinationView(for: destination)
                    }
            }
            .tag(3)
            .tabItem {
                Label("Battery", image: "ic_battery")
            }
            
            NavigationStack(path: $navigationManager.path) {
                SettingsView()
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        NavigationRouter.destinationView(for: destination)
                    }
            }
            .tag(4)
            .tabItem {
                Label("More", image: "ic_more")
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
            let inline = UITabBarItemAppearance(style: .inline)
            inline.selected.iconColor = UIColor(Color(hex: "0091FF"))
            inline.normal.iconColor = .white
            
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.inlineLayoutAppearance = inline
            
            UITabBar().standardAppearance = tabBarAppearance
            UITabBar().scrollEdgeAppearance = tabBarAppearance
        }
    }
}
