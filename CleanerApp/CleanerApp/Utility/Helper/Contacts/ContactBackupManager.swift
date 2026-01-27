//
//  ContactBackupManager.swift
//  CleanerApp
//
//  Created by iMac on 27/01/26.
//

import Foundation
import SwiftData
import FamilyControls

final class ContactBackupManager {
    // MARK: - Singleton
    static let shared = ContactBackupManager()
    private init() {}
    
    // MARK: - Context
    var context: ModelContext? = ModelContext(ModelContainer.shared)
    
    enum BackupError: LocalizedError {
        case failedToSave
        case contextNotFound
        
        var info: (title: String, message: String) {
            switch self {
            case .failedToSave:
                return ("Oops!", "Unable to perform an operation.")
                
            case .contextNotFound:
                return ("Context not found!", "Swift data context not exist.")
            }
        }
    }
    
    func configure(with context: ModelContext) {
        self.context = context
    }
    
    func fetchAllBackups() -> [ContactBackupModel] {
        guard let context else { return [] }
        
        let descriptor = FetchDescriptor<ContactBackupModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func addBackup(name: String, url: URL, contactCount: Int, completion: @escaping ((ContactBackupModel?, BackupError?) -> Void)) {
        let note = ContactBackupModel(id: UUID(), name: name, url: url, contactCount: contactCount)
        context?.insert(note)
        save { error in
            if let error {
                completion(nil, error)
            } else {
                completion(note, nil)
            }
        }
    }
    
    func deleteBackup(_ backup: ContactBackupModel, completion: @escaping ((BackupError?) -> Void)) {
        context?.delete(backup)
        save(completion: completion)
    }
    
    // MARK: - Helpers
    func save(completion: @escaping (BackupError?) -> Void) {
        guard let context = context else {
            completion(.contextNotFound)
            return
        }
        
        do {
            try context.save()
            completion(nil)
        }
        catch {
            print("❌ SwiftData Save Failed: \(error)")
            completion(.failedToSave)
        }
    }
 }
