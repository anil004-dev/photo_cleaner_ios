//
//  AppState.swift
//  CleanerApp
//
//  Created by iMac on 03/12/25.
//

import Combine
import Foundation

enum AppFlow {
    case none
    case welcome
    case onboarding
    case home
}

class AppState: ObservableObject {
    
    @Published var flow: AppFlow = .none
    @Published var homeViewModel = HomeViewModel()
    @Published var showChargingAnimation = false
    
    var isRequestingPermission: Bool = false
    
    static let shared = AppState()
    
    init() {
        updateFlow()
    }
    
    func updateFlow() {
        if UserDefaultManager.isWalkThroughCompleted {
            flow = .home
        } else {
            if PhotoLibraryManager.shared.isPermissionGranted() {
                flow = .onboarding
            } else {
                flow = .welcome
            }
        }
    }
    
    func navigateToHomeFlow() {
        NavigationManager.shared.resetNavigation()
        flow = .home
    }
    
    func updateChargingState(isCharging: Bool) {
        DispatchQueue.main.async {
            if isCharging, UserDefaultManager.selectedChargingAnimation != nil {
                AppState.shared.showChargingAnimation = true
            } else {
                AppState.shared.showChargingAnimation = false
            }
        }
    }
}
