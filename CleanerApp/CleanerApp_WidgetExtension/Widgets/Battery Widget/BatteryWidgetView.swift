//
//  BatteryWidgetView.swift
//  CleanerApp_WidgetExtension
//
//  Created by iMac on 01/01/26.
//

import WidgetKit
import SwiftUI

struct BatteryInfoEntry: TimelineEntry {
    
    var batteryLevel: Int {
        UserDefaultManager.batteryLevel
    }
    
    var batteryState: UIDevice.BatteryState {
        UserDefaultManager.batteryState
    }
    
    var isLowPowerModeOn: Bool {
        UserDefaultManager.isLowPowerModeOn
    }
    
    var brightnessLevel: Float {
        UserDefaultManager.brightnessLevel
    }
    
    var date: Date {
        UserDefaultManager.lastUpdatedTime
    }
    
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: date)
    }
    
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: date)
    }
}


struct BatteryWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: BatteryInfoEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallBatteryWidgetView(batteryInfo: entry)
                .containerBackground(Color.black, for: .widget)
        case .systemMedium:
            MediumBatteryWidgetView(batteryInfo: entry)
                .containerBackground(Color.black, for: .widget)
        case .systemLarge:
            LargeBatteryWidgetView(batteryInfo: entry)
                .containerBackground(Color.black, for: .widget)
        default:
            LargeBatteryWidgetView(batteryInfo: entry)
                .containerBackground(Color.black, for: .widget)
        }
    }
}

struct SmallBatteryWidgetView: View {
    let batteryInfo: BatteryInfoEntry

    var body: some View {
        ZStack {
            BatteryRingView(batteryInfo: batteryInfo)
        }
    }
}

struct MediumBatteryWidgetView: View {
    let batteryInfo: BatteryInfoEntry

    var body: some View {
        ZStack {
            HStack(spacing: 15) {
                BatteryRingView(batteryInfo: batteryInfo)
                BatteryDetailView(batteryInfo: batteryInfo)
            }
        }
    }
}

struct LargeBatteryWidgetView: View {
    let batteryInfo: BatteryInfoEntry

    var body: some View {
        ZStack {
            VStack(spacing: 15) {
                BatteryRingView(batteryInfo: batteryInfo)
                    .frame(height: 125)
                
                BatteryDetailView(batteryInfo: batteryInfo)
                
                VStack(alignment: .leading, spacing: 10) {
                    CNText(title: "Brightness", color: .white, font: .system(size: 15, weight: .semibold, design: .default), alignment: .leading)
                    
                    HStack(alignment: .center, spacing: 5) {
                        CNText(title: "Min", color: .white, font: .system(size: 12, weight: .regular, design: .default), alignment: .leading)
                        
                        ThickProgressBar(progress: CGFloat(batteryInfo.brightnessLevel) / 100, height: 10, label: "\(Int(batteryInfo.brightnessLevel))%")
                        
                        CNText(title: "Max", color: .white, font: .system(size: 12, weight: .regular, design: .default), alignment: .trailing)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
}
