//
//  Utility.swift
//  CleanerApp
//
//  Created by iMac on 03/12/25.
//


import UIKit

class Utility {
    class func openSettings() {
        if let settingURL = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingURL) {
            UIApplication.shared.open(settingURL)
        }
    }
    
    class func getAppName() -> String {
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
        return appName ?? "Storage Blast"
    }

    class func appVersionString() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return "Version: v\(version)"
        }
        return "Version: Unknown"
    }
    
    class func formattedSize(byte: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: byte)
    }
    
    class func fileNameTimeStamp() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter.string(from: Date())
    }
    
    class func getSizeOfMedia(items: [MediaItem]) -> String {
       let size = items.reduce(0) { $0 + $1.fileSize }
        return formattedSize(byte: size)
    }
    
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
