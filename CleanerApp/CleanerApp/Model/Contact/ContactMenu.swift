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
    let imageName: String
    let title: String
    let subTitle: String
    var contactCount: Int
}

struct ContactGroup: Identifiable {
    let id = UUID()
    var arrContacts: [ContactModel] = []
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

    // MARK: - Helpers
    var isNoName: Bool { (displayName ?? "").isEmpty }
    var isNoPhone: Bool { phoneNumbers.isEmpty }
    var isNoEmail: Bool { emailAddresses.isEmpty }
}
