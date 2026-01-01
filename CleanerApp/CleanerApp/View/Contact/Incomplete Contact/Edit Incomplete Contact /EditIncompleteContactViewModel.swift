//
//  EditIncompleteContactViewModel.swift
//  CleanerApp
//
//  Created by iMac on 10/12/25.
//

import Combine
import Foundation
import SwiftUI
import Contacts

enum FixOption: String, CaseIterable {
    case addName
    case addNumber
    case addEmail
    
    var title: String {
        switch self {
        case .addName:
            return "Add Name"
        case .addNumber:
            return "Add Number"
        case .addEmail:
            return "Add Email"
        }
    }
    
    var alertTitle: String {
        switch self {
        case .addName:
            return "Enter Name"
        case .addNumber:
            return "Enter Number"
        case .addEmail:
            return "Enter Email"
        }
    }
}

class EditIncompleteContactViewModel: ObservableObject {
    
    @Published var contact: ContactModel
    @Published var contactName: String = ""
    @Published var contactPhone: String = ""
    @Published var contactEmail: String = ""
    
    @Published var showTFAlert: (presented: Bool, option: FixOption) = (false, .addEmail)
    @Published var showEditContactView: (sheet: Bool, contact: CNContact?) = (false, nil)
    
    var didUpdatedContact: ((ContactModel) -> Void)?
    var didRemovedContact: ((ContactModel) -> Void)?
    
    var arrOptions: [FixOption] {
        var arrOptions: [FixOption] = []
        let isNoName = contact.isNoName
        let isNoNumber = contact.isNoPhone
        let isNoEmail = contact.isNoEmail
        
        if isNoName {
            arrOptions.append(FixOption.addName)
        }
        
        if isNoNumber {
            arrOptions.append(FixOption.addNumber)
        }
        
        if isNoEmail {
            arrOptions.append(FixOption.addEmail)
        }
        
        return arrOptions
    }
    
    init(contact: ContactModel) {
        self._contact = Published(initialValue: contact)
    }
    
    func contactUpdated(contact: CNContact?) {
        if let id = contact?.identifier, let contact = try? ContactDatabase.shared.fetchFreshContact(using: id) {
            self.contact = contact
            self.updateContact(updated: contact)
        }
    }
    
    func btnFixOptionAction(option: FixOption) {
        showTFAlert.option = option
        showTFAlert.presented = true
    }
    
    func btnEditFullContactAction() {
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
    
    func btnDeleteContactAction() {
        CNAlertManager.shared.showAlert(
            title: "Delete contact",
            message: "Are you sure you want to delete this contact?",
            leftButtonTitle: "Yes",
            rightButtonTitle: "Cancel",
            rightButtonRole: .cancel,
            leftButtonAction: { [weak self] in
                guard let self = self else { return }
                
                _ = ContactDatabase.shared.deleteContact(contact: self.contact)
                self.didRemovedContact?(self.contact)
                NavigationManager.shared.pop()
            }
        )
    }
    
    func btnAlertDoneAction() {
        var updated = contact

        switch showTFAlert.option {
        case .addName:
            let name = contactName.trimmed()
            if !name.isEmpty {
                updated.displayName = name

                // also split if needed
                updated.givenName = name
            }

        case .addNumber:
            let number = contactPhone.trimmed()
            if !number.isEmpty {
                updated.phoneNumbers = [number]
            }

        case .addEmail:
            let email = contactEmail.trimmed()
            if !email.isEmpty {
                updated.emailAddresses = [email]
            }
        }
        
        updateContact(updated: updated)
    }
    
    func updateContact(updated: ContactModel) {
        Task {
            do {
                try ContactDatabase.shared.saveEditedContact(updated)
                await MainActor.run {
                    self.contact = updated
                    self.didUpdatedContact?(self.contact)
                }
            } catch {
                print("❌ failed to save edited contact:", error)
            }
        }
    }
}
