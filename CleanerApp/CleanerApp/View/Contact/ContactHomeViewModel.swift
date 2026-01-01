//
//  ContactHomeViewModel.swift
//  CleanerApp
//
//  Created by iMac on 09/12/25.
//

import Combine
import Foundation
import SwiftUI
 
class ContactHomeViewModel: ObservableObject {
    
    @Published var arrMenuSection: [ContactSection] = [
        ContactSection(
            title: "Contact to Manage",
            arrMenu: [
                ContactMenu(imageName: "", title: "Duplicates", subTitle: "Names - Numbers - Emails", contactCount: 0),
                ContactMenu(imageName: "", title: "Incompleted Contacts", subTitle: "No Names - Numbers - Emails", contactCount: 0)
            ]
        ),
        ContactSection(
            title: "Full Directory",
            arrMenu: [
                ContactMenu(imageName: "",  title: "All Contacts", subTitle: "", contactCount: 0)
            ]
        ),
        ContactSection(
            title: "Safekeeping",
            arrMenu: [
                ContactMenu(imageName: "",  title: "Backups", subTitle: "", contactCount: 0)
            ]
        )
    ]
    
    @Published var arrContacts: [ContactModel] = []
    @Published var duplicateContact: DuplicateContactModel = DuplicateContactModel()
    @Published var incompleteContact: IncompleteContactModel = IncompleteContactModel()
    
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
                    let contacts = try await ContactDatabase.shared.fetchAllContacts()
                    CNLoader.dismiss()
                    
                    setContacts(contacts: contacts)
                } catch let error {
                    CNLoader.dismiss()
                    CNAlertManager.shared.showAlert(
                        title: "Error occured",
                        message: error.localizedDescription
                    )
                }
            }
        }
    }
    
    func setContacts(contacts: [ContactModel]) {
        duplicateContact = ContactDatabase.shared.buildDuplicateModel(from: contacts)
        arrMenuSection[0].arrMenu[0].contactCount = duplicateContact.count
        
        incompleteContact = ContactDatabase.shared.buildIncompleteModel(from: contacts)
        arrMenuSection[0].arrMenu[1].contactCount = incompleteContact.count
        
        arrContacts = contacts
        arrMenuSection[1].arrMenu[0].contactCount = contacts.count
        
        arrMenuSection[2].arrMenu[0].contactCount = ContactDatabase.shared.fetchBackups().count
    }
    
    func btnMenuAction(menu: ContactMenu) {
        if menu.title == "Duplicates" {
            openDuplicateContactMenuView()
        }
        
        if menu.title == "Incompleted Contacts" {
            openIncompleteContactMenuView()
        }
        
        if menu.title == "All Contacts" {
            openAllContactsView()
        }
        
        if menu.title == "Backups" {
            openBackupContactView()
        }
    }
    
    func openDuplicateContactMenuView() {
        guard duplicateContact.count != 0 else { return }
        let viewModel = DuplicateContactMenuViewModel(duplicateContact: duplicateContact)
        NavigationManager.shared.push(to: .duplicateContactMenuView(destination: DuplicateContactMenuDestination(viewModel: viewModel)))
    }
    
    func openIncompleteContactMenuView() {
        guard incompleteContact.count != 0 else { return }
        let viewModel = IncompleteContactMenuViewModel(incompleteContact: incompleteContact)
        NavigationManager.shared.push(to: .incompleteContactMenuView(destination: IncompleteContactMenuDestination(viewModel: viewModel)))
    }
    
    func openAllContactsView() {
        NavigationManager.shared.push(to: .allContactsView)
    }
    
    func openBackupContactView() {
        NavigationManager.shared.push(to: .backupContactView)
    }
}
