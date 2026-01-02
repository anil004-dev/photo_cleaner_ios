//
//  BatteryInfoProvider.swift
//  CleanerApp_WidgetExtension
//
//  Created by iMac on 01/01/26.
//

import WidgetKit

struct BatteryInfoProvider: TimelineProvider {
    func placeholder(in context: Context) -> BatteryInfoEntry {
        BatteryInfoEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (BatteryInfoEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BatteryInfoEntry>) -> Void) {
        let entry = loadEntry()
        let nextUpdate = Calendar.current.date(byAdding: .second, value: 60, to: Date())!

        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func loadEntry() -> BatteryInfoEntry {
        return BatteryInfoEntry()
    }
}
