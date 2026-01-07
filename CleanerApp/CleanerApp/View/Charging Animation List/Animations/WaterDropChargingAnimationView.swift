//
//  WaterDropPreview.swift
//  CleanerApp
//
//  Created by iMac on 05/01/26.
//

import UIKit
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
        .background(Color.black.ignoresSafeArea())
    }
}

// MARK: - Main Charging Animation View
struct WaterDropChargingAnimationView: View {

    @EnvironmentObject var batteryMonitor: BatteryMonitor
    @State private var phase: CGFloat = 0
    @State private var drops: [Raindrop] = []

    private let containerWidth: CGFloat = 200
    private let containerHeight: CGFloat = 340

    private let waveTimer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    private let dropSpawnTimer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
   
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            RoundedRectangle(cornerRadius: 32)
            .stroke(Color.white.opacity(0.25), lineWidth: 2)
            .frame(width: containerWidth, height: containerHeight)
            .overlay(
                ZStack {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color.black)
                        .frame(width: containerWidth, height: containerHeight)
                        .overlay {
                            ForEach(drops) { drop in
                                Circle()
                                    .fill(Color.cyan.opacity(0.9))
                                    .frame(width: 6, height: 6)
                                    .position(x: drop.x, y: drop.y)
                            }
                        }
                        .background(Color.black.ignoresSafeArea())
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                        .clipped()
                    
                    LiquidWaveShape(
                        progress: batteryMonitor.level,
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
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                    
                    CNText(title: "\(Int(batteryMonitor.level * 100))%", color: .white, font: .system(size: 15, weight: .bold, design: .default))
                }
            )
        }
        .onReceive(waveTimer) { _ in
            phase += 0.05
        }
        .onReceive(dropSpawnTimer) { _ in
            if batteryMonitor.level != 1 {
                spawnDrop()
            }
        }
    }

    private func spawnDrop() {
        let x = CGFloat.random(in: 5...(containerWidth - 5))
        let startY: CGFloat = -10
        let targetY = (containerHeight * (1 - batteryMonitor.level)) + 12
        let drop = Raindrop(x: x, y: startY)
        let id = drop.id
        
        withAnimation {
            drops.append(drop)
        } completion: {
            withAnimation(.easeInOut(duration: 1)) {
                if let index = drops.firstIndex(where: { $0.id == id }) {
                    drops[index].y = targetY
                }
            } completion: {
                drops.removeAll { $0.id == id }
            }
        }
    }
}

// MARK: - Liquid Wave Shape
struct LiquidWaveShape: Shape {
    
    var progress: CGFloat
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
