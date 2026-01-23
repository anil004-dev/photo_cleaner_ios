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
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB, .useTB, .useAll]
        formatter.countStyle = .decimal
        formatter.includesUnit = true
        formatter.isAdaptive = true
        return formatter.string(fromByteCount: Int64(bytes))
    }
}
