//
//  StorageWidget.swift
//  CleanerApp_WidgetExtension
//
//  Created by iMac on 01/01/26.
//

import SwiftUI
import WidgetKit

struct StorageWidget: Widget {
    let kind = "StorageWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StorageInfoProvider()) { entry in
            StorageWidgetView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
