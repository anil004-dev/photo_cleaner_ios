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
                Label("Home", systemImage: "house")
            }
            
            NavigationStack(path: $navigationManager.path) {
                ContactHomeView()
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        NavigationRouter.destinationView(for: destination)
                    }
            }
            .tag(1)
            .tabItem {
                Label("Contact", systemImage: "person.crop.circle")
            }
            
            NavigationStack(path: $navigationManager.path) {
                WidgetListView()
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        NavigationRouter.destinationView(for: destination)
                    }
            }
            .tag(2)
            .tabItem {
                Label("Widget", systemImage: "widget.small.badge.plus")
            }
            
            NavigationStack(path: $navigationManager.path) {
                ChargingAnimationListView()
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        NavigationRouter.destinationView(for: destination)
                    }
            }
            .tag(3)
            .tabItem {
                Label("Charging Animation", systemImage: "powerplug.portrait")
            }
        }
        .tint(.white)
    }
}
