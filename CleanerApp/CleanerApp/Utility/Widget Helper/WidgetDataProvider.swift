//
//  WidgetDataProvider.swift
//  CleanerApp
//
//  Created by iMac on 01/01/26.
//

import UIKit
import WidgetKit

final class WidgetDataProvider {
    
    // MARK: - Singleton
    static let shared = WidgetDataProvider()
    private init() {}
    
    // MARK: - Public API
    func updateAll() {
        updateBatteryInformation()
        updateLowPowerMode()
        updateBrightnessLevel()
        updateTimestamp()
        updateStorageInformation()
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func updateBatteryInformation() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        let batteryLevel = max(0, Int(UIDevice.current.batteryLevel * 100))
        let batteryState = UIDevice.current.batteryState
        
        UserDefaultManager.batteryLevel = batteryLevel
        UserDefaultManager.batteryState = batteryState
    }
    
    func updateLowPowerMode() {
        let isLowPowerModeOn = ProcessInfo.processInfo.isLowPowerModeEnabled
        UserDefaultManager.isLowPowerModeOn = isLowPowerModeOn
    }
    
    func updateBrightnessLevel() {
        let brightness = UIScreen.main.brightness * 100
        UserDefaultManager.brightnessLevel = Float(brightness)
    }
    
    func updateTimestamp() {
        UserDefaultManager.lastUpdatedTime = Date.now
    }
    
    func updateStorageInformation() {
        
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        do {
            let values = try url.resourceValues(forKeys: [
                .volumeTotalCapacityKey,
                .volumeAvailableCapacityKey
            ])
            
            guard let totalStorage = values.volumeTotalCapacity, let freeStorage = values.volumeAvailableCapacity else {
                return
            }
            
            let usedStorage = totalStorage - freeStorage
            let usedStoragePercentage = Float(usedStorage) / Float(totalStorage) * 100
            
            UserDefaultManager.freeStorage = Float(freeStorage)
            UserDefaultManager.totalStorage = Float(totalStorage)
            UserDefaultManager.usedStorage = Float(usedStorage)
            UserDefaultManager.usedStoragePercentage = usedStoragePercentage
        } catch {
            print("❌ Storage fetch failed:", error)
        }
    }
}
