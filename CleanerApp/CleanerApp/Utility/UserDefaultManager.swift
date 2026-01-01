//
//  UserDefaultManager.swift
//  CleanerApp
//
//  Created by iMac on 01/01/26.
//

import UIKit

struct UDKeys {
    static let appGroupId = "group.com.storage.blast.app"
    static let batteryLevel = "batteryLevel"
    static let batteryStateRaw = "batteryState"
    static let isLowPowerModeOn = "isLowPowerModeOn"
    static let brightnessLevel = "brightnessLevel"
    static let lastUpdatedTime = "lastUpdatedTime"
    static let selectedWidgetRaw = "selectedWidgetRaw"
    
    static let totalStorage = "totalStorage"
    static let usedStorage = "usedStorage"
    static let usedStoragePercentage = "usedStoragePercentage"
    static let freeStorage = "freeStorage"
}

enum WidgetKind: Int, CaseIterable, Identifiable {
    case battery = 0
    case storage = 1
    var id: Int { rawValue }
}

final class UserDefaultManager {
    
    private init() {}
    
    // MARK: - App Group Storage
    static let userDefault = UserDefaults(suiteName: UDKeys.appGroupId) ?? UserDefaults.standard
    
    static var batteryLevel: Int {
        get {
            return userDefault.integer(forKey: UDKeys.batteryLevel)
        }
        set {
            userDefault.setValue(newValue, forKey: UDKeys.batteryLevel)
        }
    }
    
    static var batteryState: UIDevice.BatteryState {
        get {
            let state = userDefault.integer(forKey: UDKeys.batteryStateRaw)
            return UIDevice.BatteryState(rawValue: state) ?? .unknown
        }
        set {
            userDefault.setValue(newValue.rawValue, forKey: UDKeys.batteryStateRaw)
        }
    }
    
    static var isLowPowerModeOn: Bool {
        get {
            return userDefault.bool(forKey: UDKeys.isLowPowerModeOn)
        }
        set {
            userDefault.setValue(newValue, forKey: UDKeys.isLowPowerModeOn)
        }
    }
    
    static var brightnessLevel: Float {
        get {
            return userDefault.float(forKey: UDKeys.brightnessLevel)
        }
        set {
            userDefault.setValue(newValue, forKey: UDKeys.brightnessLevel)
        }
    }
    
    static var lastUpdatedTime: Date {
        get {
            return userDefault.value(forKey: UDKeys.lastUpdatedTime) as? Date ?? Date()
        }
        set {
            userDefault.setValue(newValue, forKey: UDKeys.lastUpdatedTime)
        }
    }
    
    static var selectedWidget: WidgetKind {
        get {
            let raw = userDefault.integer(forKey: UDKeys.selectedWidgetRaw)
            return WidgetKind(rawValue: raw) ?? WidgetKind.battery
        }
        set {
            userDefault.setValue(newValue.rawValue, forKey: UDKeys.selectedWidgetRaw)
        }
    }
    
    static var usedStorage: Float {
        get {
            return userDefault.float(forKey: UDKeys.usedStorage)
        }
        set {
            userDefault.setValue(newValue, forKey: UDKeys.usedStorage)
        }
    }
    
    static var totalStorage: Float {
        get {
            return userDefault.float(forKey: UDKeys.totalStorage)
        }
        set {
            userDefault.setValue(newValue, forKey: UDKeys.totalStorage)
        }
    }
    
    static var freeStorage: Float {
        get {
            return userDefault.float(forKey: UDKeys.freeStorage)
        }
        set {
            userDefault.setValue(newValue, forKey: UDKeys.freeStorage)
        }
    }
    
    static var usedStoragePercentage: Float {
        get {
            return userDefault.float(forKey: UDKeys.usedStoragePercentage)
        }
        set {
            userDefault.setValue(newValue, forKey: UDKeys.usedStoragePercentage)
        }
    }
}
