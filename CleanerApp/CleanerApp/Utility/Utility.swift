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
    
    class func formattedSize(byte: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: byte)
        
//        guard byte > 0 else {
//            return "0 KB"
//        }
//        
//        let units = ["KB", "MB", "GB", "TB"]
//        let base: Double = 1000
//        
//        var size = Double(byte)
//        var unitIndex = -1
//        
//        while size >= base && unitIndex < units.count - 1 {
//            size /= base
//            unitIndex += 1
//        }
//        
//        // Ensure minimum KB
//        if unitIndex == -1 {
//            size /= base
//            unitIndex = 0
//        }
//        
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .decimal
//        formatter.maximumFractionDigits = 2
//        formatter.minimumFractionDigits = 2
//        
//        let value =
//        formatter.string(from: NSNumber(value: size))
//        ?? String(format: "%.\(2)f", size)
//        
//        return "\(value) \(units[unitIndex])"
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

    class func appVersionString() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return "Version: v\(version)"
        }
        return "Version: Unknown"
    }
}
