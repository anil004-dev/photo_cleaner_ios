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
    @Published var arrContactToDelete: [ContactModel] = []
    
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
    
    func selectContact(contact: ContactModel) {
        guard let contactIndex = arrContacts.firstIndex(where: { $0.id == contact.id }) else { return }

        arrContacts[contactIndex].isSelected.toggle()

        let id = contact.id

        if let index = arrContactToDelete.firstIndex(where: {
            $0.id == id
        }) {
            arrContactToDelete.remove(at: index)
        } else {
            arrContactToDelete.append(arrContacts[contactIndex])
        }
    }

    func btnSelectAllAction() {
        arrContactToDelete = arrContacts
        
        for index in 0..<arrContacts.count {
            arrContacts[index].isSelected = true
        }
    }
    
    func btnDeselectAllAction() {
        arrContactToDelete = []
        
        for index in 0..<arrContacts.count {
            arrContacts[index].isSelected = false
        }
    }
    
    func btnDeleteAction() {
        guard arrContactToDelete.isEmpty == false else { return }
        
        do {
            try ContactDatabase.shared.deleteContacts(contacts: arrContactToDelete)
            arrContacts.removeAll(where: { arrContactToDelete.contains($0) })
            arrContactToDelete.removeAll()
            
            if arrContacts.isEmpty {
                NavigationManager.shared.pop()
            }
        } catch {
            CNAlertManager.shared.showAlert(
                title: "Error occured",
                message: "Unable to delete selected contacts"
            )
        }
    }
}
