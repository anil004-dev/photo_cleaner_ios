//
//  BackupContactViewModel.swift
//  CleanerApp
//
//  Created by iMac on 15/12/25.
//

import Combine
import Foundation

class BackupContactViewModel: ObservableObject {
    
    @Published var arrBackups: [ContactBackupModel] = []
    @Published var showShareSheet: (sheet: Bool, url: URL?) = (false, nil)

    func onAppear() {
        fetchBackups()
    }
    
    func fetchBackups() {
        arrBackups = ContactDatabase.shared.fetchBackups()
    }
    
    func prepareBackup() {
        CNLoader.show()
        
        Task {
            let (backup, error) = await ContactDatabase.shared.generateVCF()
            CNLoader.dismiss()
            
            if let backup {
                showShareSheet.url = backup.url
                showShareSheet.sheet = true
                
                fetchBackups()
            } else {
                CNAlertManager.shared.showAlert(
                    title: "Error occured",
                    message: error ?? "Unable to generate contact backup"
                )
            }
        }
    }
    
    func btnBackupRowAction(backup: ContactBackupModel) {
        showShareSheet.url = backup.url
        showShareSheet.sheet = true
    }
}
