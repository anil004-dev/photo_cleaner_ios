//
//  ScoreCache.swift
//  CleanerApp
//
//  Created by iMac on 09/12/25.
//

// ScoreCache.swift
// Persistent cache for image scoring

import UIKit
import Photos
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

// MARK: - Persistent caches
actor HashCache {
    static let shared = HashCache()
    private var storage: [String: (a: UInt64, d: UInt64)] = [:]
    private let fileURL: URL

    init() {
        let fm = FileManager.default
        let support = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = support.appendingPathComponent("SimilarMedia", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        fileURL = dir.appendingPathComponent("hashCache.json")
        Task { await loadFromDisk() }
    }

    func get(_ key: String) -> (UInt64, UInt64)? { storage[key] }
    func set(_ key: String, a: UInt64, d: UInt64) {
        storage[key] = (a, d)
        saveToDisk()
    }

    private func loadFromDisk() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let dict = try? JSONDecoder().decode([String: [UInt64]].self, from: data) {
            for (k, v) in dict { if v.count == 2 { storage[k] = (v[0], v[1]) } }
        }
    }

    private func saveToDisk() {
        let dict = storage.mapValues { [$0.a, $0.d] }
        if let data = try? JSONEncoder().encode(dict) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}
