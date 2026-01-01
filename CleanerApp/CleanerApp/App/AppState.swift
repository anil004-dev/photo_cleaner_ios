//
//  AppState.swift
//  CleanerApp
//
//  Created by iMac on 03/12/25.
//

import Combine

enum AppFlow {
    case none
    case home
}

class AppState: ObservableObject {
    
    @Published var flow: AppFlow = .none
    @Published var homeViewModel = HomeViewModel()
    var isRequestingPermission: Bool = false
    
    static let shared = AppState()
    
    init() {
        updateFlow()
    }
    
    func updateFlow() {
        flow = .home
        //NavigationManager.shared.resetNavigation()
    }
}
