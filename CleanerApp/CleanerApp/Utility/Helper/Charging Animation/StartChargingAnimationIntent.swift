//
//  StartChargingAnimationIntent.swift
//  CleanerApp
//
//  Created by iMac on 05/01/26.
//


import AppIntents
import UIKit

struct StartChargingAnimationIntent: AppIntent {

    static var title: LocalizedStringResource = "Start Charging Animation"
    static var description = IntentDescription(
        "Opens the app and shows the charging animation"
    )

    /// This is CRITICAL
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        await AppState.shared.updateChargingState(isCharging: UIDevice.current.batteryState == .charging)
        return .result()
    }
}
