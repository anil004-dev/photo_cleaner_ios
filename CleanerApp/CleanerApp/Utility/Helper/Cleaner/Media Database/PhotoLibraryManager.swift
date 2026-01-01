//
//  PhotoLibraryManager.swift
//  CleanerApp
//
//  Created by iMac on 03/12/25.
//

import Photos
import UIKit

final class PhotoLibraryManager {
    
    static let shared = PhotoLibraryManager()
    private init() {}
    
    func requestAuthorization() async -> PHAuthorizationStatus {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        return status
    }
    
    func checkPermission() async -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            return true
        case .notDetermined:
            AppState.shared.isRequestingPermission = true
            
            let status = await requestAuthorization()
            
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                AppState.shared.isRequestingPermission = false
            }
            
            if status == .authorized || status == .limited {
                return true
            } else {
                CNAlertManager.shared.showAlert(
                    title: "Access Denied",
                    message: "Photo Library access was not granted. You can continue using other features or enable access later in Settings."
                )
                
                return false
            }
        case .denied, .restricted:
            CNAlertManager.shared.showAlert(
                title: "Photo Library Access Needed",
                message: "To use this feature, please enable Photo Library access in Settings. You can continue without it.",
                leftButtonTitle: "Cancel",
                leftButtonRole: .none,
                rightButtonTitle: "Go to Settings",
                rightButtonRole: .none,
                rightButtonAction: {
                    Utility.openSettings()
                }
            )
            return false
        @unknown default:
            CNAlertManager.shared.showAlert(
                title: "Photo Library Access Needed",
                message: "To use this feature, please enable Photo Library access in Settings. You can continue without it.",
                leftButtonTitle: "Cancel",
                leftButtonRole: .none,
                rightButtonTitle: "Go to Settings",
                rightButtonRole: .none,
                rightButtonAction: {
                    Utility.openSettings()
                }
            )
            return false
        }
    }
}
