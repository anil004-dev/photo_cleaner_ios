//
//  ContactMenu.swift
//  CleanerApp
//
//  Created by iMac on 09/12/25.
//

import SwiftUI
import Contacts
import Foundation

struct ContactSection: Identifiable {
    let id = UUID()
    let title: String
    var arrMenu: [ContactMenu]
}

struct ContactMenu: Identifiable {
    let id = UUID()
    let imageName: ImageResource
    let title: String
    var subTitle: String
    var contactCount: Int
}

struct ContactGroup: Identifiable {
    let id = UUID()
    var arrContacts: [ContactModel] = []
    
    var isAllSelected: Bool {
        arrContacts.allSatisfy({ $0.isSelected })
    }
}

struct ContactModel: Identifiable, Hashable {
    let id: String
    var displayName: String?
    var givenName: String
    var familyName: String
    
    var phoneNumbers: [String]
    var emailAddresses: [String]
    
    var raw: CNContact
    var isSelected: Bool = false
    
    var  intialName: String {
        let parts = (displayName ?? "")
            .split(separator: " ")
            .filter { !$0.isEmpty }

        if parts.count >= 2 {
            let first = parts.first?.first
            let last = parts.last?.first
            return "\(first ?? " ")\(last ?? " ")".uppercased()
        } else if let first = parts.first?.first {
            return String(first).uppercased()
        }

        return ""
    }


    // MARK: - Helpers
    var isNoName: Bool { (displayName ?? "").isEmpty }
    var isNoPhone: Bool { phoneNumbers.isEmpty }
    var isNoEmail: Bool { emailAddresses.isEmpty }
}
