//
//  StorageInfoProvider.swift
//  CleanerApp_WidgetExtension
//
//  Created by iMac on 01/01/26.
//

import WidgetKit

struct StorageInfoProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> StorageInfoEntry {
        StorageInfoEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (StorageInfoEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StorageInfoEntry>) -> Void) {
        let entry = loadEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func loadEntry() -> StorageInfoEntry {
        return StorageInfoEntry()
    }
}
