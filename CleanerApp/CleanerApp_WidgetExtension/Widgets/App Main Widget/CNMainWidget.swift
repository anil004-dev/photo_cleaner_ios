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
                .containerBackground(Color.primOrange, for: .widget)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct CNWidgetEntryPointView: View {
    var body: some View {
        if UserDefaultManager.selectedWidget == .battery {
            BatteryWidgetView(entry: BatteryInfoEntry())
                .containerBackground(Color.primOrange, for: .widget)
        } else {
            StorageWidgetView(entry: StorageInfoEntry())
                .containerBackground(Color.primOrange, for: .widget)
        }
    }
}

class Utility {
    class func formatStorage(bytes: Float) -> String {
        let measurement = Measurement(value: Double(bytes), unit: UnitInformationStorage.bytes)
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .medium
        formatter.unitOptions = [.naturalScale]
        formatter.numberFormatter.maximumFractionDigits = 0
        formatter.numberFormatter.minimumFractionDigits = 0
        
        return formatter.string(from: measurement)
    }
}
