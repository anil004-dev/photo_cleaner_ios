//
//  ContactHomeViewModel.swift
//  CleanerApp
//
//  Created by iMac on 09/12/25.
//

import Combine
import Foundation
import SwiftUI
import Contacts

class ContactHomeViewModel: ObservableObject {
    
    @Published var arrContactMenu: [ContactMenu] = [
        ContactMenu(imageName: .icDuplicateNew, title: "Duplicate Contacts", subTitle: "", contactCount: 0),
        ContactMenu(imageName: .icIncompleteNew, title: "Incompletes", subTitle: "", contactCount: 0),
        ContactMenu(imageName: .icAllContactNew, title: "All Contacts", subTitle: "", contactCount: 0),
        ContactMenu(imageName: .icBackupContactNew, title: "Backup Contacts", subTitle: "", contactCount: 0)
    ]
    
    @Published var arrContacts: [ContactModel] = []
    @Published var duplicateContact: DuplicateContactModel = DuplicateContactModel()
    @Published var incompleteContact: IncompleteContactModel = IncompleteContactModel()
    
    @Published var showPermissionSection: Bool? = nil
    
    func onAppear() {
        fetchContacts()
    }
    
    func fetchContacts() {
        if ContactManager.shared.getPermissionStatus() == .authorized {
            self.showPermissionSection = false
        }
        
        Task {
            if await ContactManager.shared.checkPermission(showAlert: false) {
                self.showPermissionSection = false
                
                do {
                    let contacts = try await ContactDatabase.shared.fetchAllContacts()
                    
                    setContacts(contacts: contacts)
                } catch let error {
                    CNLoader.dismiss()
                    CNAlertManager.shared.showAlert(
                        title: "Error occured",
                        message: error.localizedDescription
                    )
                }
            } else {
                self.showPermissionSection = true
            }
        }
    }
    
    func setContacts(contacts: [ContactModel]) {
        duplicateContact = ContactDatabase.shared.buildDuplicateModel(from: contacts)
        arrContactMenu[0].subTitle = "\(duplicateContact.contactCount) duplicates"
        arrContactMenu[0].contactCount = duplicateContact.contactCount
        
        incompleteContact = ContactDatabase.shared.buildIncompleteModel(from: contacts)
        arrContactMenu[1].subTitle = "\(incompleteContact.contactCount) incomplete"
        arrContactMenu[1].contactCount = incompleteContact.contactCount
        
        arrContacts = contacts
        arrContactMenu[2].subTitle = "\(contacts.count) contacts"
        arrContactMenu[2].contactCount = contacts.count
        
        let backupCount = ContactDatabase.shared.fetchBackups().count
        arrContactMenu[3].subTitle = "\(backupCount) backups"
        arrContactMenu[3].contactCount = backupCount
    }
    
    func btnGoToSettingsAction() {
        Utility.openSettings()
    }
    
    func btnMenuAction(menu: ContactMenu) {
        if menu.title == "Duplicate Contacts" {
            openDuplicateContactGroupView()
        }
        
        if menu.title == "Incompletes" {
            openIncompleteContactMenuView()
        }
        
        if menu.title == "All Contacts" {
            openAllContactsView()
        }
        
        if menu.title == "Backup Contacts" {
            openBackupContactView()
        }
    }
    
    func openDuplicateContactGroupView() {
        guard duplicateContact.contactCount != 0 else { return }
        let viewModel = DuplicateContactGroupViewModel(duplicateContact: duplicateContact)
        NavigationManager.shared.push(to: .duplicateContactGroupView(destination: DuplicateContactGroupViewDestination(viewModel: viewModel)))
    }
    
    func openIncompleteContactMenuView() {
        guard incompleteContact.contactCount != 0 else { return }
        let viewModel = IncompleteContactListViewModel(incompleteContact: incompleteContact)
        NavigationManager.shared.push(to: .incompleteContactListView(destination: IncompleteContactListDestination(viewModel: viewModel)))
    }
    
    func openAllContactsView() {
        NavigationManager.shared.push(to: .allContactsView)
    }
    
    func openBackupContactView() {
        NavigationManager.shared.push(to: .backupContactView)
    }
}
