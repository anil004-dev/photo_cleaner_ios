//
//  IncompleteContactModel.swift
//  CleanerApp
//
//  Created by iMac on 09/12/25.
//

import Foundation

// MARK: - Incomplete
enum IncompleteType: String, CaseIterable {
    case noName = "Incomplete Names"
    case noNumber = "Incomplete Numbers"
    case noEmail = "Incomplete Emails"
}

struct IncompleteContactModel: Identifiable {
    let id = UUID()
    
    var arrNoName: IncompleteContact = IncompleteContact(type: .noName)
    var arrNoNumber: IncompleteContact = IncompleteContact(type: .noNumber)
    var arrNoEmail: IncompleteContact = IncompleteContact(type: .noEmail)
    
    var count: Int {
        arrNoName.arrContactGroup.count +
        arrNoNumber.arrContactGroup.count +
        arrNoEmail.arrContactGroup.count
    }
    var contactCount: Int {
        arrNoName.contactCount +
        arrNoNumber.contactCount +
        arrNoEmail.contactCount
    }
}

struct IncompleteContact: Identifiable {
    let id = UUID()
    let type: IncompleteType
    var arrContactGroup: [ContactGroup] = []
    
    var title: String {
        return type.rawValue
    }
    
    var contactCount: Int {
        arrContactGroup.reduce(0) { $0 + $1.arrContacts.count }
    }
}

extension IncompleteContactModel {
    mutating func updateEveryList(with contact: ContactModel) {
        
        // update arrNoName
        for groupIndex in arrNoName.arrContactGroup.indices {
            if let contactIndex = arrNoName.arrContactGroup[groupIndex].arrContacts.firstIndex(where: { $0.id == contact.id }) {
                arrNoName.arrContactGroup[groupIndex].arrContacts[contactIndex] = contact
            }
        }
        
        // update arrNoNumber
        for groupIndex in arrNoNumber.arrContactGroup.indices {
            if let contactIndex = arrNoNumber.arrContactGroup[groupIndex].arrContacts.firstIndex(where: { $0.id == contact.id }) {
                arrNoNumber.arrContactGroup[groupIndex].arrContacts[contactIndex] = contact
            }
        }
        
        // update arrNoEmail
        for groupIndex in arrNoEmail.arrContactGroup.indices {
            if let contactIndex = arrNoEmail.arrContactGroup[groupIndex].arrContacts.firstIndex(where: { $0.id == contact.id }) {
                arrNoEmail.arrContactGroup[groupIndex].arrContacts[contactIndex] = contact
            }
        }
        
        removeContactsGroupIfNeeded()
    }
    
    mutating func removeContact(contact: ContactModel) {
        arrNoName.arrContactGroup.removeAll { group in
            group.arrContacts.contains(where: { $0.id == contact.id })
        }

        arrNoNumber.arrContactGroup.removeAll { group in
            group.arrContacts.contains(where: { $0.id == contact.id })
        }

        arrNoEmail.arrContactGroup.removeAll { group in
            group.arrContacts.contains(where: { $0.id == contact.id })
        }

        removeContactsGroupIfNeeded()
    }
    
    mutating func removeContactsGroupIfNeeded() {
        arrNoName.arrContactGroup.removeAll { group in
            guard let c = group.arrContacts.first else { return true }
            return !c.isNoName && !c.isNoPhone && !c.isNoEmail
        }
        
        arrNoNumber.arrContactGroup.removeAll { group in
            guard let c = group.arrContacts.first else { return true }
            return !c.isNoName && !c.isNoPhone && !c.isNoEmail
        }
        
        arrNoEmail.arrContactGroup.removeAll { group in
            guard let c = group.arrContacts.first else { return true }
            return !c.isNoName && !c.isNoPhone && !c.isNoEmail
        }
    }
}
