//
//  StorageWidget.swift
//  CleanerApp
//
//  Created by iMac on 01/01/26.
//

import SwiftUI
import WidgetKit

struct StorageWidget: Widget {
    let kind = "StorageWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: StorageInfoProvider()
        ) { entry in
            StorageWidgetView(entry: entry)
        }
        .configurationDisplayName("Storage")
        .description("Storage usage information")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
