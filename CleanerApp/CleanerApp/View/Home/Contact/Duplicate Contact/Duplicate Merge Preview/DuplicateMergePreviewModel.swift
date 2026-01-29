//
//  DuplicateMergePreviewModel.swift
//  CleanerApp
//
//  Created by iMac on 09/12/25.
//

import Combine
import Contacts

class DuplicateMergePreviewModel: ObservableObject {
    
    @Published var arrContactGroup: [ContactGroup] = []
    @Published var showContactPreview: (sheet: Bool, contact: CNContact) = (false, CNContact())
    
    init(arrContactGroup: [ContactGroup]) {
        self._arrContactGroup = Published(wrappedValue: arrContactGroup)
    }
    
    func getContactName(contactGroup: ContactGroup) -> String {
        return contactGroup.arrContacts.first?.displayName ?? "No Name"
    }
  
    func getContactNumber(contactGroup: ContactGroup) -> String {
        let allPhoneNumbers = contactGroup.arrContacts.flatMap { $0.phoneNumbers }
        let uniqueNumbers = Array(Set(allPhoneNumbers.filter { !$0.isEmpty }))
            .sorted()

        let phoneNumberStr = uniqueNumbers.joined(separator: " / ")
        print(phoneNumberStr)
        return phoneNumberStr
    }
    
    func showContactPreview(contactGroup: ContactGroup) {
        showContactPreview.contact = ContactDatabase.shared.buildMergedPreview(for: contactGroup)
        showContactPreview.sheet = true
    }
    
    func btnMergeAction() {
        CNLoader.show()
        
        Task {
            do {
                try await ContactDatabase.shared.mergeAll(groups: arrContactGroup)
                CNLoader.dismiss()
                
                CNAlertManager.shared.showAlert(
                    title: "Success",
                    message: "Contacts merged successfully",
                    leftButtonAction: { [weak self] in
                        guard self != nil else { return }
                        NavigationManager.shared.popToRoot()
                    }
                )
            } catch {
                CNLoader.dismiss()
                CNAlertManager.shared.showAlert(
                    title: "Unable to merge",
                    message: "Failed to merge contacts"
                )
            }
        }
    }
}
