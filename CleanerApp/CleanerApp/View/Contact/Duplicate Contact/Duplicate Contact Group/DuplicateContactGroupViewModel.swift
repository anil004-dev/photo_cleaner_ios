//
//  DuplicateContactGroupViewModel.swift
//  CleanerApp
//
//  Created by iMac on 09/12/25.
//

import Combine

class DuplicateContactGroupViewModel: ObservableObject {
    
    @Published var duplicateContact: DuplicateContact = DuplicateContact(type: .duplicateName)
    @Published var arrContactGroupToMerge: [ContactGroup] = []
    @Published var contactToMergeCount: Int = 0
    @Published var isMergeButtonEnable: Bool = false
    
    init(duplicateContact: DuplicateContact) {
        self._duplicateContact = Published(wrappedValue: duplicateContact)
        updateMergeButton()
    }
    
    func selectContact(contact: ContactModel) {
        guard let groupIndex = duplicateContact.arrContactGroup.firstIndex(where: {
            $0.arrContacts.contains(where: { $0.id == contact.id })
        }) else { return }
        
        var group = duplicateContact.arrContactGroup[groupIndex]
        
        if let contactIndex = group.arrContacts.firstIndex(where: { $0.id == contact.id }) {
            group.arrContacts[contactIndex].isSelected.toggle()
            duplicateContact.arrContactGroup[groupIndex].arrContacts[contactIndex].isSelected.toggle()
        }
        
        let selectedContacts = group.arrContacts.filter { $0.isSelected }
        
        if selectedContacts.isEmpty {
            arrContactGroupToMerge.removeAll { $0.id == group.id }
        } else {
            var newGroup = group
            newGroup.arrContacts = selectedContacts
            
            if let existingIndex = arrContactGroupToMerge.firstIndex(where: { $0.id == newGroup.id }) {
                arrContactGroupToMerge[existingIndex] = newGroup
            } else {
                arrContactGroupToMerge.append(newGroup)
            }
        }
        
        updateMergeButton()
    }
    
    func updateMergeButton() {
        // 1. No groups → disable
        guard !arrContactGroupToMerge.isEmpty else {
            isMergeButtonEnable = false
            contactToMergeCount = 0
            return
        }
        
        isMergeButtonEnable = arrContactGroupToMerge.allSatisfy { group in
            group.arrContacts.count >= 2
        }
        
        contactToMergeCount = arrContactGroupToMerge
            .flatMap { $0.arrContacts }
            .count
    }

    func openPreviewScreen() {
        guard !arrContactGroupToMerge.isEmpty else { return }
        let viewModel = DuplicateMergePreviewModel(arrContactGroup: arrContactGroupToMerge)
        NavigationManager.shared.push(to: .duplicateMergePreview(destination: DuplicateMergePreviewDestination(viewModel: viewModel)))
    }
}
