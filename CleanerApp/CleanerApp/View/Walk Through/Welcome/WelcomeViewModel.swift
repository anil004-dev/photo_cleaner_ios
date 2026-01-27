//
//  WelcomeViewModel.swift
//  CleanerApp
//
//  Created by iMac on 23/01/26.
//

import Combine

class WelcomeViewModel: ObservableObject {
    
    func btnGetStartedAction() {
        UserDefaultManager.isPhotosPermissionRequested = true
        
        Task {
            _ = await PhotoLibraryManager.shared.checkPermission(showAlert: false)
            NavigationManager.shared.push(to: .onboardingView)
        }
    }
}
