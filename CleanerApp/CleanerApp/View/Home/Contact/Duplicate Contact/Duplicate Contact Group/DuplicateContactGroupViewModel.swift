//
//  DuplicateContactGroupViewModel.swift
//  CleanerApp
//
//  Created by iMac on 09/12/25.
//

import Combine
import SwiftUI

class DuplicateContactGroupViewModel: ObservableObject {
    
    @Published var duplicateContact: DuplicateContactModel
    @Published var arrContactGroupToMerge: [ContactGroup] = []
    @Published var contactToMergeCount: Int = 0
    @Published var isMergeButtonEnable: Bool = false
    
    init(duplicateContact: DuplicateContactModel) {
        self._duplicateContact = Published(wrappedValue: duplicateContact)
        updateMergeButton()
    }
    
    func selectContact(contact: ContactModel) {
        withAnimation {
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
        }
        
        updateMergeButton()
    }
    
    func openPreviewScreen() {
        guard !arrContactGroupToMerge.isEmpty else { return }
        let viewModel = DuplicateMergePreviewModel(arrContactGroup: arrContactGroupToMerge)
        NavigationManager.shared.push(to: .duplicateMergePreview(destination: DuplicateMergePreviewDestination(viewModel: viewModel)))
    }
    
    func btnSelectAll(contactGroup: ContactGroup) {
        withAnimation {
            arrContactGroupToMerge.removeAll { $0.id == contactGroup.id }
            
            guard let groupIndex = duplicateContact.arrContactGroup.firstIndex(where: { $0.id == contactGroup.id }) else {
                return
            }
            let group = duplicateContact.arrContactGroup[groupIndex]
            
            for index in 0..<group.arrContacts.count {
                duplicateContact.arrContactGroup[groupIndex].arrContacts[index].isSelected = true
            }
            
            arrContactGroupToMerge.append(duplicateContact.arrContactGroup[groupIndex])
        }
        
        updateMergeButton()
    }
    
    func btnDeselectAll(contactGroup: ContactGroup) {
        withAnimation {
            arrContactGroupToMerge.removeAll { $0.id == contactGroup.id }
            
            guard let groupIndex = duplicateContact.arrContactGroup.firstIndex(where: { $0.id == contactGroup.id }) else {
                return
            }
            let group = duplicateContact.arrContactGroup[groupIndex]
            
            for index in 0..<group.arrContacts.count {
                duplicateContact.arrContactGroup[groupIndex].arrContacts[index].isSelected = false
            }
        }
        
        updateMergeButton()
    }
    
    func btnSelectAllAction() {
        withAnimation {
            arrContactGroupToMerge.removeAll()
            
            duplicateContact.arrContactGroup.forEach { group in
                btnSelectAll(contactGroup: group)
            }
        }
    }
    
    func btnDeselectAllAction() {
        withAnimation {
            arrContactGroupToMerge.removeAll()
            
            duplicateContact.arrContactGroup.forEach { group in
                btnDeselectAll(contactGroup: group)
            }
        }
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
}
