//
//  IncompleteContactListViewModel.swift
//  CleanerApp
//
//  Created by iMac on 10/12/25.
//

import Foundation
import Combine
import Contacts

class IncompleteContactListViewModel: ObservableObject {
    
    @Published var incompleteContact: IncompleteContactModel = IncompleteContactModel()
    @Published var arrContactToDelete: [ContactModel] = []
    @Published var showEditContactView: (sheet: Bool, contact: CNContact?) = (false, nil)
    @Published var refreshId = UUID()
    
    init(incompleteContact: IncompleteContactModel) {
        self._incompleteContact = Published(wrappedValue: incompleteContact)
    }
    
    func selectContact(contact: ContactModel) {
        guard let contactIndex = incompleteContact.arrContacts.firstIndex(where: { $0.id == contact.id }) else { return }

        incompleteContact.arrContacts[contactIndex].isSelected.toggle()

        let id = contact.id

        if let index = arrContactToDelete.firstIndex(where: {
            $0.id == id
        }) {
            arrContactToDelete.remove(at: index)
        } else {
            arrContactToDelete.append(incompleteContact.arrContacts[contactIndex])
        }
    }
    
    func btnSelectAllAction() {
        arrContactToDelete = incompleteContact.arrContacts
        
        for index in 0..<incompleteContact.arrContacts.count {
            incompleteContact.arrContacts[index].isSelected = true
        }
    }
    
    func btnDeselectAllAction() {
        arrContactToDelete = []
        
        for index in 0..<incompleteContact.arrContacts.count {
            incompleteContact.arrContacts[index].isSelected = false
        }
    }
    
    func contactUpdated(contact: CNContact?) {
        if let id = showEditContactView.contact?.identifier,
            let contact = try? ContactDatabase.shared.fetchFreshContact(using: id),
            let index = incompleteContact.arrContacts.firstIndex(where: { $0.id == id }) {
            
            let isSelected = incompleteContact.arrContacts[index].isSelected
            
            incompleteContact.arrContacts[index] = contact
            incompleteContact.arrContacts[index].isSelected = isSelected
        }
    }
    
    func btnEditFullContactAction(contact: ContactModel) {
        do {
            let contactModel = try ContactDatabase.shared.fetchFreshContact(using: contact.raw.identifier)
            showEditContactView.contact = contactModel.raw
            showEditContactView.sheet = true
        } catch {
            CNAlertManager.shared.showAlert(
                title: "Error occured",
                message: "Unable to edit a full contact"
            )
        }
    }
    
    func btnDeleteAction() {
        guard arrContactToDelete.isEmpty == false else { return }
        
        do {
            try ContactDatabase.shared.deleteContacts(contacts: arrContactToDelete)
            let ids = Set(arrContactToDelete.map(\.id))
            var updated = incompleteContact
            
            updated.arrContacts.removeAll {
                ids.contains($0.id)
            }
            
            incompleteContact = updated
            arrContactToDelete.removeAll()
            
            if incompleteContact.arrContacts.isEmpty {
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
