//
//  DuplicateHashCache.swift
//  CleanerApp
//
//  Created by iMac on 23/01/26.
//


import Photos
import CryptoKit
import Foundation

// MARK: - Persistent SHA256 Hash Cache
actor DuplicateHashCache {
    static let shared = DuplicateHashCache()
    private var storage: [String: String] = [:] // assetId -> SHA256 hex
    private let fileURL: URL

    init() {
        let fm = FileManager.default
        let support = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = support.appendingPathComponent("DuplicateMedia", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        fileURL = dir.appendingPathComponent("duplicateHashCache.json")
        Task { await loadFromDisk() }
    }

    func get(_ key: String) -> String? { storage[key] }
    func set(_ key: String, value: String) {
        storage[key] = value
        saveToDisk()
    }

    private func loadFromDisk() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let dict = try? JSONDecoder().decode([String: String].self, from: data) {
            storage = dict
        }
    }

    private func saveToDisk() {
        if let data = try? JSONEncoder().encode(storage) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}
