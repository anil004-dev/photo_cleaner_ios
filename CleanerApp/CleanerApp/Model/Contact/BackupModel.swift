//
//  BackupModel.swift
//  CleanerApp
//
//  Created by iMac on 15/12/25.
//

import Foundation

struct BackupModel: Identifiable {
    let id = UUID()
    let name: String
    let url: URL
}
