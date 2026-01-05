//
//  BatteryMonitor.swift
//  CleanerApp
//
//  Created by iMac on 05/01/26.
//


import SwiftUI
import UIKit
import Combine

final class BatteryMonitor: ObservableObject {

    static let shared = BatteryMonitor()

    @Published var level: CGFloat = 0.0
    @Published var isCharging: Bool = false

    private init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        update()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(update),
            name: UIDevice.batteryLevelDidChangeNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(update),
            name: UIDevice.batteryStateDidChangeNotification,
            object: nil
        )
    }

    @objc private func update() {
        let device = UIDevice.current
        level = CGFloat(max(0, device.batteryLevel))
        isCharging = device.batteryState == .charging
        AppState.shared.updateChargingState(isCharging: isCharging)
    }
}
