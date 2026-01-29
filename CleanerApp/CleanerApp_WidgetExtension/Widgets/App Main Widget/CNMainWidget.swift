//
//  CNMainWidget.swift
//  CleanerApp
//
//  Created by iMac on 02/01/26.
//


import WidgetKit
import SwiftUI

struct CNMainWidget: Widget {
    let kind = "CleanerApp_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: StorageInfoProvider()
        ) { entry in
            CNWidgetEntryPointView()
                .containerBackground(Color.btnBlue, for: .widget)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct CNWidgetEntryPointView: View {
    var body: some View {
        if UserDefaultManager.selectedWidget == .battery {
            BatteryWidgetView(entry: BatteryInfoEntry())
                .containerBackground(Color.btnBlue, for: .widget)
        } else {
            StorageWidgetView(entry: StorageInfoEntry())
                .containerBackground(Color.btnBlue, for: .widget)
        }
    }
}

class Utility {
    class func formatStorage(bytes: Float) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB, .useTB, .useAll]
        formatter.countStyle = .decimal
        formatter.includesUnit = true
        formatter.isAdaptive = true
        return formatter.string(fromByteCount: Int64(bytes))
    }
}
