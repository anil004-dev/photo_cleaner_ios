//
//  BatteryWidget.swift
//  CleanerApp
//
//  Created by iMac on 01/01/26.
//


import WidgetKit
import SwiftUI

struct BatteryWidget: Widget {

    let kind = "BatteryWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: BatteryInfoProvider()
        ) { entry in
            BatteryWidgetView(entry: entry)
        }
        .supportedFamilies([
            .systemSmall, .systemMedium, .systemLarge
        ])
    }
}
