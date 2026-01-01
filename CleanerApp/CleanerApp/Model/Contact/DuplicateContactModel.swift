//
//  DuplicateContactModel.swift
//  CleanerApp
//
//  Created by iMac on 09/12/25.
//

import Foundation

// MARK: - Duplicate
enum DuplicateType: String, CaseIterable {
    case duplicateName = "Duplicate Names"
    case duplicateNumber = "Duplicate Numbers"
    case duplicateEmail = "Duplicate Emails"
}

struct DuplicateContactModel: Identifiable {
    let id = UUID()
    var arrDuplicateName: DuplicateContact = DuplicateContact(type: .duplicateName)
    var arrDuplicateNumber: DuplicateContact = DuplicateContact(type: .duplicateNumber)
    var arrDuplicateEmail: DuplicateContact = DuplicateContact(type: .duplicateEmail)
    
    var count: Int {
        arrDuplicateName.arrContactGroup.count +
        arrDuplicateNumber.arrContactGroup.count +
        arrDuplicateEmail.arrContactGroup.count
    }
    
    var contactCount: Int {
        return arrDuplicateName.arrContactGroup.count + arrDuplicateNumber.arrContactGroup.count + arrDuplicateEmail.arrContactGroup.count
    }
}

struct DuplicateContact: Identifiable {
    let id = UUID()
    let type: DuplicateType
    var arrContactGroup: [ContactGroup] = []
    
    var title: String {
        return type.rawValue
    }
    
    var contactCount: Int {
        arrContactGroup.reduce(0) { sum, group in  sum + group.arrContacts.count }
    }
}
