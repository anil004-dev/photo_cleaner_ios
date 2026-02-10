//
//  StorageWidgetView.swift
//  CleanerApp_WidgetExtension
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
                .containerBackground(Color.primOrange, for: .widget)
        case .systemMedium:
            MediumStorageWidgetView(storageInfo: entry)
                .containerBackground(Color.primOrange, for: .widget)
        default:
            SmallStorageWidgetView(storageInfo: entry)
                .containerBackground(Color.primOrange, for: .widget)
        }
    }
}

struct SmallStorageWidgetView: View {
    let storageInfo: StorageInfoEntry

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "externaldrive.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.white)
                        .frame(width: 39, height: 29)
                    
                    Spacer(minLength: 0)
                    
                    CNText(title: "\(Utility.formatStorage(bytes: UserDefaultManager.freeStorage)) FREE", color: .white, font: .system(size: 12, weight: .regular, design: .default), alignment: .trailing)
                }
                
                Spacer()
                
                let totalStorage = storageInfo.totalStorage
                let freeStorage = storageInfo.freeStorage
                
                let usedStorage = totalStorage - freeStorage
                let usedStoragePerc = Int((usedStorage / totalStorage) * 100)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 5) {
                    CNText(title: "STORAGE USED", color: .white, font: .system(size: 15, weight: .bold, design: .default), alignment: .leading)
                    
                    CNText(title: "\(Utility.formatStorage(bytes: UserDefaultManager.usedStorage)) of \(Utility.formatStorage(bytes: UserDefaultManager.totalStorage))", color: .white, font: .system(size: 14, weight: .regular, design: .default), alignment: .leading, minimumScale: 0.8)
                }
                
                Spacer()
                
                CNText(title: "\(usedStoragePerc)%", color: .white, font: .system(size: 36, weight: .semibold, design: .default), alignment: .leading)
                    .padding(.bottom, -7)
            }
        }
    }
}

struct MediumStorageWidgetView: View {
    let storageInfo: StorageInfoEntry

    var body: some View {
        HStack(alignment: .center) {
            let totalStorage = storageInfo.totalStorage
            let freeStorage = storageInfo.freeStorage
            
            let usedStorage = totalStorage - freeStorage
            let usedStoragePerc = Int((usedStorage / totalStorage) * 100)
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "externaldrive.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.white)
                        .frame(width: 39, height: 29)
                    
                    Spacer(minLength: 0)
                }
                
                Spacer()
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 5) {
                    CNText(title: "STORAGE USED", color: .white, font: .system(size: 15, weight: .bold, design: .default), alignment: .leading)
                    
                    CNText(title: "\(Utility.formatStorage(bytes: usedStorage)) of \(Utility.formatStorage(bytes: totalStorage))", color: .white, font: .system(size: 14, weight: .regular, design: .default), alignment: .leading, minimumScale: 0.8)
                }
                
                Spacer()
                
                HStack(alignment: .bottom, spacing: 10) {
                    CNText(title: "\(usedStoragePerc)%", color: .white, font: .system(size: 36, weight: .semibold, design: .default), alignment: .leading)
                        .padding(.bottom, -7)
                    
                    CNText(title: "\(Utility.formatStorage(bytes: freeStorage)) FREE", color: .white, font: .system(size: 12, weight: .regular, design: .default), alignment: .trailing)
                    
                    Spacer(minLength: 0)
                }
            }
            
            Spacer(minLength: 0)
            
            ZStack {
                CNCircularProgressView(progress: Double(usedStorage / totalStorage), lineWidth: 12)
                
                Image(.icDbBlue)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 85, height: 85)
                    .clipShape(Circle())
            }
            .frame(width: 110, height: 110)
        }
    }
}
