//
//  NavigationManager.swift
//  CleanerApp
//
//  Created by IMac on 03/12/25.
//

import Combine
import SwiftUI

class NavigationManager: ObservableObject {
    
    static let shared = NavigationManager()
    @Published var path = NavigationPath()
    
    enum AppFlow {
        case splash
        case home
    }
    
    // Push a new destination
    func push(to destination: NavigationDestination) {
        path.append(destination)
    }
    
    // Pop last item
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    // Pop to root
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    // Reset all navigation
    func resetNavigation() {
        path = NavigationPath()
    }
    
    /// Call this when we want to go directly to LoginView by resetting the flow
    func resetToLogin() {
        resetNavigation()
    }
}
