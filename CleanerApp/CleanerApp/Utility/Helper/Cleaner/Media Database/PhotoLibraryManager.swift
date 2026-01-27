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
    
    func isPermissionGranted() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        return status == .authorized || status == .limited
    }
    
    func requestAuthorization() async -> PHAuthorizationStatus {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        return status
    }
    
    func checkPermission(showAlert: Bool = true) async -> Bool {
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
                if showAlert {
                    CNAlertManager.shared.showAlert(
                        title: "Photo Access Denied",
                        message: "Photo Library access was not granted. please allow access to your Photo Library in Settings."
                    )
                }
                return false
            }
        case .denied, .restricted:
            if showAlert {
                CNAlertManager.shared.showAlert(
                    title: "Photo Access Required",
                    message: "Please allow access to your Photo Library in Settings.",
                    rightButtonTitle: "Open Settings",
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
                    title: "Photo Access Required",
                    message: "Please allow access to your Photo Library in Settings.",
                    rightButtonTitle: "Open Settings",
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
