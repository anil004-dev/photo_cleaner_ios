//
//  BackupModel.swift
//  CleanerApp
//
//  Created by iMac on 15/12/25.
//

import SwiftData
import Foundation

@Model
class ContactBackupModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var url: URL
    var contactCount: Int
    var createdAt: Date
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd MMM, yyyy"
        return formatter.string(from: createdAt)
    }
    
    init(id: UUID, name: String, url: URL, contactCount: Int) {
        self.id = id
        self.name = name
        self.contactCount = contactCount
        self.url = url
        self.createdAt = Date()
    }
}
