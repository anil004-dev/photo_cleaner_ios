//
//  ContactManager.swift
//  CleanerApp
//
//  Created by iMac on 09/12/25.
//

import Foundation
import Contacts

class ContactManager {
    static let shared = ContactManager()
    private let store = CNContactStore()
    
    func getPermissionStatus() -> CNAuthorizationStatus {
        CNContactStore.authorizationStatus(for: .contacts)
    }
    
    func requestAuthorization() async throws -> Bool {
        return try await store.requestAccess(for: .contacts)
    }
    
    func checkPermission(showAlert: Bool = true) async -> Bool {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        
        switch status {
        case .authorized, .limited:
            return true
        case .notDetermined:
            AppState.shared.isRequestingPermission = true
            
            do {
                let isGranted = try await requestAuthorization()
                
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    AppState.shared.isRequestingPermission = false
                }
                
                if isGranted {
                    return true
                } else {
                    if showAlert {
                        CNAlertManager.shared.showAlert(
                            title: "Access Denied",
                            message: "Contact access was not granted. You can continue using other features or enable access later in Settings."
                        )
                    }
                    return false
                }
            } catch {
                if showAlert {
                    CNAlertManager.shared.showAlert(
                        title: "Access Denied",
                        message: "Contact access was not granted. You can continue using other features or enable access later in Settings."
                    )
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    AppState.shared.isRequestingPermission = false
                }
                return false
            }
            
        case .denied, .restricted:
            if showAlert {
                CNAlertManager.shared.showAlert(
                    title: "Contact Access Needed",
                    message: "To use this feature, please enable Contact access in Settings. You can continue without it.",
                    leftButtonTitle: "Cancel",
                    leftButtonRole: .none,
                    rightButtonTitle: "Go to Settings",
                    rightButtonRole: .none,
                    rightButtonAction: {
                        Utility.openSettings()
                    }
                )
            }
            
            return false
        @unknown default:
            if showAlert {
                CNAlertManager.shared.showAlert(
                    title: "Contact Access Needed",
                    message: "To use this feature, please enable Contact access in Settings. You can continue without it.",
                    leftButtonTitle: "Cancel",
                    leftButtonRole: .none,
                    rightButtonTitle: "Go to Settings",
                    rightButtonRole: .none,
                    rightButtonAction: {
                        Utility.openSettings()
                    }
                )
            }
            
            return false
        }
    }
}
