//
//  File.swift
//  CleanerApp
//
//  Created by iMac on 27/01/26.
//


import SwiftData
import Foundation

extension ModelContainer {
    
    static let shared: ModelContainer = {
        let schema = Schema([ContactBackupModel.self])
        let config = ModelConfiguration()
        return try! ModelContainer(for: schema, configurations: config)
    }()
}
