//
//  BackupContactViewModel.swift
//  CleanerApp
//
//  Created by iMac on 15/12/25.
//

import Combine
import Foundation

class BackupContactViewModel: ObservableObject {
    
    @Published var arrBackups: [BackupModel] = []
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
            let (url, error) = await ContactDatabase.shared.generateVCF()
            CNLoader.dismiss()
            
            if let url {
                showShareSheet.url = url
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
    
    func btnBackupRowAction(backup: BackupModel) {
        showShareSheet.url = backup.url
        showShareSheet.sheet = true
    }
}
