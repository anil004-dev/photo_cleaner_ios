//
//  ScoreCache.swift
//  CleanerApp
//
//  Created by iMac on 09/12/25.
//

// ScoreCache.swift
// Persistent cache for image scoring

import Foundation

actor ScoreCache {

    static let shared = ScoreCache()

    private var storage: [String: Int] = [:]
    private let fileURL: URL

    init() {
        let fm = FileManager.default

        let support = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = support.appendingPathComponent("SimilarMedia", isDirectory: true)

        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }

        fileURL = dir.appendingPathComponent("scoreCache.json")

        Task {
            await self.loadFromDisk()
        }
    }

    // MARK: Public API

    func get(_ key: String) -> Int? {
        storage[key]
    }

    func set(_ key: String, value: Int) {
        storage[key] = value
        saveToDisk()
    }

    // MARK: Disk I/O
    private func loadFromDisk() {
        guard let data = try? Data(contentsOf: fileURL) else { return }

        if let dict = try? JSONDecoder().decode([String: Int].self, from: data) {
            storage = dict
        }
    }

    private func saveToDisk() {
        if let data = try? JSONEncoder().encode(storage) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}
