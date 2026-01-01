//
//  IncompleteContactListViewModel.swift
//  CleanerApp
//
//  Created by iMac on 10/12/25.
//

import Foundation
import Combine

class IncompleteContactListViewModel: ObservableObject {
    
    @Published var incompleteContact: IncompleteContact = IncompleteContact(type: .noName)
    var didUpdatedContact: ((ContactModel) -> Void)?
    var didRemovedContact: ((ContactModel) -> Void)?
    
    init(incompleteContact: IncompleteContact) {
        self._incompleteContact = Published(wrappedValue: incompleteContact)
    }
    
    func updateContact() {
        incompleteContact.arrContactGroup.removeAll { group in
            guard let c = group.arrContacts.first else { return true }
            return !c.isNoName && !c.isNoPhone && !c.isNoEmail
        }
    }
    
    func openEditContactView(contact: ContactModel) {
        let viewModel = EditIncompleteContactViewModel(contact: contact)
        viewModel.didUpdatedContact = { [weak self] contact in
            guard let self = self else { return }
            
            if let indexGroup = incompleteContact.arrContactGroup.firstIndex(where: {
                $0.arrContacts.contains(where: { $0.id == contact.id }) }),
                let indexContact = incompleteContact.arrContactGroup[indexGroup].arrContacts.firstIndex(where: { $0.id == contact.id }) {
                incompleteContact.arrContactGroup[indexGroup].arrContacts[indexContact] = contact
            }
            
            self.didUpdatedContact?(contact)
            updateContact()
        }
        
        viewModel.didRemovedContact = { [weak self] contact in
            guard let self = self else { return }
            
            if let indexGroup = incompleteContact.arrContactGroup.firstIndex(where: {
                $0.arrContacts.contains(where: { $0.id == contact.id }) }),
                let indexContact = incompleteContact.arrContactGroup[indexGroup].arrContacts.firstIndex(where: { $0.id == contact.id }) {
                incompleteContact.arrContactGroup.remove(at: indexContact)
            }
            
            self.didRemovedContact?(contact)
            updateContact()
        }
        
        NavigationManager.shared.push(to: .editIncompleteContactView(destination: EditIncompleteContactDestination(viewModel: viewModel)))
    }
}
