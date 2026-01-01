//
//  AllContactsViewModel.swift
//  CleanerApp
//
//  Created by iMac on 15/12/25.
//

import Foundation
import Combine

class AllContactsViewModel: ObservableObject {
    
    @Published var arrContacts: [ContactModel] = []
    
    func onAppear() {
        fetchContacts()
    }
    
    func fetchContacts() {
        DispatchQueue.main.async {
            CNLoader.show()
        }
        
        Task {
            if await ContactManager.shared.checkPermission() {
                do {
                    let arrContacts = try await ContactDatabase.shared.fetchAllContacts()
                    self.arrContacts = arrContacts
                    CNLoader.dismiss()
                } catch let error {
                    CNLoader.dismiss()
                    CNAlertManager.shared.showAlert(
                        title: "Error occured",
                        message: error.localizedDescription,
                        leftButtonAction: {
                            NavigationManager.shared.pop()
                        }
                    )
                }
            }
        }
    }
}
