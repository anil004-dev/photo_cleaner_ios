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
                .containerBackground(Color.btnBlue, for: .widget)
        case .systemMedium:
            MediumBatteryWidgetView(batteryInfo: entry)
                .containerBackground(Color.btnBlue, for: .widget)
        default:
            SmallBatteryWidgetView(batteryInfo: entry)
                .containerBackground(Color.btnBlue, for: .widget)
        }
    }
}

struct SmallBatteryWidgetView: View {
    let batteryInfo: BatteryInfoEntry

    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 16) {
                let batteryLevel = batteryInfo.batteryLevel
                
                HStack(alignment: .center, spacing: 0) {
                    CNText(title: "BATTERY", color: .white, font: .system(size: 15, weight: .bold, design: .default), alignment: .leading)
                    
                    Spacer(minLength: 0)
                    
                    CNText(title: "\(batteryLevel)%", color: .white, font: .system(size: 15, weight: .bold, design: .default), alignment: .leading)
                }
                
                ZStack {
                    CNCircularProgressView(progress: Double(batteryLevel) / 100, lineWidth: 10)
                    
                    Image(.icPowerBlue)
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                        .clipShape(Circle())
                }
            }
        }
    }
}

struct MediumBatteryWidgetView: View {
    let batteryInfo: BatteryInfoEntry

    var body: some View {
        HStack(alignment: .center) {
            let batteryLevel = batteryInfo.batteryLevel
            let isLowPowerModeOn = batteryInfo.isLowPowerModeOn
            
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "bolt.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.white)
                        .frame(width: 38, height: 38)
                    
                    CNText(title: "Low Power Mode: \(isLowPowerModeOn ? "ON" : "OFF")", color: .white, font: .system(size: 15, weight: .regular, design: .default), alignment: .leading)
                    
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 0) {
                    CNText(title: "BATTERY USAGE", color: .white, font: .system(size: 15, weight: .bold, design: .default), alignment: .leading)
                    
                    CNText(title: "\(batteryLevel)%", color: .white, font: .system(size: 36, weight: .semibold, design: .default), alignment: .leading, minimumScale: 0.8)
                }
                .padding(.bottom, -7)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            ZStack {
                CNCircularProgressView(progress: Double(batteryLevel) / 100, lineWidth: 12)
                
                Image(.icPowerBlue)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 85, height: 85)
                    .clipShape(Circle())
            }
            .frame(width: 110, height: 110)
        }
    }
}
