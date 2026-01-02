//
//  BatteryRingView.swift
//  CleanerApp_WidgetExtension
//
//  Created by iMac on 01/01/26.
//


import SwiftUI

struct BatteryRingView: View {
    
    let batteryInfo: BatteryInfoEntry
    private var progress: CGFloat {
        CGFloat(batteryInfo.batteryLevel) / 100
    }
    
    var body: some View {
        VStack(spacing: 15) {
            let isCharging = batteryInfo.batteryState == .charging
            
            CNText(title: isCharging ? "Charging.." : "Battery", color: .white, font: .system(size: 14, weight: .bold, design: .default), alignment: .center)
                .font(.system(size: 14, weight: .bold, design: .default))

            ZStack {
                Circle()
                    .stroke(
                        Color.white.opacity(0.12),
                        lineWidth: 10
                    )

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                Color.blue,
                                Color.cyan,
                                Color.green,
                                Color.blue
                            ]),
                            center: .center
                        ),
                        style: StrokeStyle(
                            lineWidth: 10,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 3) {
                    if isCharging {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.cyan)
                            .font(.system(size: 14))
                    }
                    
                    CNText(title: "\(Int(batteryInfo.batteryLevel))%", color: .white, font: .system(size: 17, weight: .bold), alignment: .center)

                    CNText(title: "Current level", color: .gray, font: .system(size: 8, weight: .bold), alignment: .center)
                }
            }
        }
    }
}
