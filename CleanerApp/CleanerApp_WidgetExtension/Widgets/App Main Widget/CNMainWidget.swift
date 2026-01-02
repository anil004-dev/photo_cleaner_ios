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
                .containerBackground(Color.black, for: .widget)
        }
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct CNWidgetEntryPointView: View {
    var body: some View {
        if UserDefaultManager.selectedWidget == .battery {
            BatteryWidgetView(entry: BatteryInfoEntry())
                .containerBackground(Color.black, for: .widget)
        } else {
            StorageWidgetView(entry: StorageInfoEntry())
                .containerBackground(Color.black, for: .widget)
        }
    }
}
