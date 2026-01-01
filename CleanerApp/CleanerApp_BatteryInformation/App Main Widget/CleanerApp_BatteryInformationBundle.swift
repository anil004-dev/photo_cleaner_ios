//
//  CleanerApp_BatteryInformationBundle.swift
//  CleanerApp_BatteryInformation
//
//  Created by iMac on 01/01/26.
//

import WidgetKit
import SwiftUI

@main
struct CleanerApp_BatteryInformationBundle: WidgetBundle {
    var body: some Widget {
        CNMainWidget()
    }
}

struct CNMainWidget: Widget {
    let kind = "StorageWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: StorageInfoProvider()
        ) { entry in
            CNWidgetEntryPoint()
                .containerBackground(Color.black, for: .widget)
        }
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct CNWidgetEntryPoint: View {
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
