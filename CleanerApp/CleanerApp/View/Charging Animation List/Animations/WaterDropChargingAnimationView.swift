//
//  WaterDropPreview.swift
//  CleanerApp
//
//  Created by iMac on 05/01/26.
//

import SwiftUI
import Combine

// MARK: - Raindrop Model
struct Raindrop: Identifiable {
    let id = UUID()
    let x: CGFloat
    var y: CGFloat
}

struct WaterDropChargingAnimationPreview: View {
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            WaterDropChargingAnimationView()
                .padding()
        }
    }
}

// MARK: - Main Charging Animation View
struct WaterDropChargingAnimationView: View {

    @StateObject private var battery = BatteryMonitor.shared

    @State private var phase: CGFloat = 0
    @State private var drops: [Raindrop] = []

    private let containerWidth: CGFloat = 200
    private let containerHeight: CGFloat = 340

    private let waveTimer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    private let dropTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 32,
                bottomTrailingRadius: 32,
                topTrailingRadius: 0
            )
            .stroke(Color.white.opacity(0.25), lineWidth: 2)
            .frame(width: containerWidth, height: containerHeight)
            .overlay(
                ZStack {
                    
                    LiquidWaveShape(
                        progress: battery.level,
                        waveHeight: 8,
                        phase: phase
                    )
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.cyan.opacity(0.9),
                                Color.blue
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 32, bottomTrailingRadius: 32, topTrailingRadius: 0))
                    
                    if battery.isCharging {
                        ForEach(drops) { drop in
                            Circle()
                                .fill(Color.cyan.opacity(0.9))
                                .frame(width: 6, height: 6)
                                .position(x: drop.x, y: drop.y)
                        }
                    }
                }
            )
        }
        .onReceive(waveTimer) { _ in
            phase += 0.05
            updateDrops()
        }
        .onReceive(dropTimer) { _ in
            if battery.isCharging {
                spawnDrop()
            }
        }
    }

    // MARK: - Raindrop Logic (VISUAL ONLY)
    private func spawnDrop() {
        let x = CGFloat.random(in: 20...(containerWidth - 20))
        drops.append(Raindrop(x: x, y: -10))
    }

    private func updateDrops() {
        for index in drops.indices {
            drops[index].y += 4
        }

        // Drops disappear when touching water
        drops.removeAll { drop in
            let waterY = containerHeight * (1 - battery.level)
            return drop.y >= waterY
        }
    }
}

// MARK: - Liquid Wave Shape

struct LiquidWaveShape: Shape {
    var progress: CGFloat        // 0 → 1
    var waveHeight: CGFloat
    var phase: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(progress, phase) }
        set {
            progress = newValue.first
            phase = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        let waterLevel = rect.height * (1 - progress)

        var path = Path()
        path.move(to: CGPoint(x: 0, y: waterLevel))

        for x in stride(from: 0, through: rect.width, by: 1) {
            let relativeX = x / rect.width
            let sine = sin(relativeX * .pi * 2 + phase)
            let y = waterLevel + sine * waveHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()

        return path
    }
}
