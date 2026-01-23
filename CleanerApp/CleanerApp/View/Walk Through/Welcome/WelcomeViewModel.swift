//
//  WelcomeViewModel.swift
//  CleanerApp
//
//  Created by iMac on 23/01/26.
//

import Combine

class WelcomeViewModel: ObservableObject {
    
    func btnGetStartedAction() {
        Task {
            if await PhotoLibraryManager.shared.checkPermission() {
                NavigationManager.shared.push(to: .onboardingView)
            }
        }
    }
}
