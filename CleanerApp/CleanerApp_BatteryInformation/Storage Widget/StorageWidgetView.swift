//
//  StorageWidgetView.swift
//  CleanerApp
//
//  Created by iMac on 01/01/26.
//


import WidgetKit
import SwiftUI

struct StorageInfoEntry: TimelineEntry {
    
    var usedStorage: Float {
        UserDefaultManager.usedStorage
    }
    
    var freeStorage: Float {
        UserDefaultManager.freeStorage
    }
    
    var totalStorage: Float {
        UserDefaultManager.totalStorage
    }
    
    var usedStoragePercentage: Float {
        return UserDefaultManager.usedStoragePercentage
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
    
    func formatStorage(bytes: Float) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB, .useTB, .useAll]
        formatter.countStyle = .decimal
        formatter.includesUnit = true
        formatter.isAdaptive = true

        return formatter.string(fromByteCount: Int64(bytes))
    }
}


struct StorageWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: StorageInfoEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallStorageWidgetView(storageInfo: entry)
                .containerBackground(Color.black, for: .widget)
        case .systemMedium:
            MediumStorageWidgetView(storageInfo: entry)
                .containerBackground(Color.black, for: .widget)
        case .systemLarge:
            LargeStorageWidgetView(storageInfo: entry)
                .containerBackground(Color.black, for: .widget)
        default:
            LargeStorageWidgetView(storageInfo: entry)
                .containerBackground(Color.black, for: .widget)
        }
    }
}

struct SmallStorageWidgetView: View {
    
    let storageInfo: StorageInfoEntry

    var body: some View {
        ZStack {
            StorageRingView(storageInfo: storageInfo)
        }
    }
}

struct MediumStorageWidgetView: View {
    
    let storageInfo: StorageInfoEntry

    var body: some View {
        ZStack {
            HStack(spacing: 15) {
                StorageRingView(storageInfo: storageInfo)
                StorageGraphView(storageInfo: storageInfo)
            }
        }
    }
}


struct LargeStorageWidgetView: View {
    
    let storageInfo: StorageInfoEntry

    var body: some View {
        ZStack {
            VStack(spacing: 15) {
                StorageRingView(storageInfo: storageInfo)
                    .frame(height: 125)
                
                StorageGraphView(storageInfo: storageInfo)
                
                VStack(alignment: .leading, spacing: 10) {
                    CNText(title: "Storage", color: .white, font: .system(size: 15, weight: .semibold, design: .default), alignment: .leading)
                    
                    HStack(alignment: .center, spacing: 5) {
                        CNText(title: "Min", color: .white, font: .system(size: 12, weight: .regular, design: .default), alignment: .leading)
                        let progress: CGFloat = {
                            guard storageInfo.totalStorage > 0 else { return 0 }
                            return CGFloat(storageInfo.usedStorage / storageInfo.totalStorage)
                        }()

                        ThickProgressBar(progress: progress, height: 10, label: "\(Int(storageInfo.usedStoragePercentage))%")
                        
                        CNText(title: "Max", color: .white, font: .system(size: 12, weight: .regular, design: .default), alignment: .trailing)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
}
