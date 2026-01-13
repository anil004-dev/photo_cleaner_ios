//
//  AngularRingAnimationView.swift
//  CleanerApp
//
//  Created by iMac on 12/01/26.
//

import SwiftUI
import Combine

struct AngularRingAnimationPreview: View {
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            AngularRingAnimationView()
                .frame(height: 500)
                .padding([.top, .leading, .trailing])
        }
        .background(Color.black.ignoresSafeArea())
    }
}

// MARK: - Main Charging Animation View
struct AngularRingAnimationView: View {
    
    @EnvironmentObject var batteryMonitor: BatteryMonitor
    @State var color: Color = .white
    let startDate = Date()
    
    private let speed: Double = 0.25          // particle speed
    private let baseSize: CGFloat = 2       // minimum particle size
    private let sizeGrowth: CGFloat = 5     // size increase toward center
    private let curlStrength: CGFloat = 15    // swirl amount
    private let streamCount: Int = 90
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .center, spacing: 0) {
                    dateAndTimeSection
                    Spacer()
                }
                
                ringSection(geometry: geometry)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private var dateAndTimeSection: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(Date(), style: .time)
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)
            
            Text(Date(), style: .date)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    private func ringSection(geometry: GeometryProxy) -> some View {
        ZStack {
            chargingEnergyCore(geometry: geometry)
            
            CNText(
                title: "\(Int(batteryMonitor.level * 100))%",
                color: .white,
                font: .system(size: 20, weight: .bold),
                alignment: .center
            )
        }
    }
    
    private func chargingEnergyCore(geometry: GeometryProxy) -> some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let minSide = min(size.width, size.height)
                
                let coreRadius = minSide * 0.12
                let outerRadius = minSide * 0.45
                
                // MARK: - Energy Streams
                for i in 0..<streamCount {
                    let seed = Double(i) * 13.13
                    let angle = seed.truncatingRemainder(dividingBy: .pi * 2)
                    
                    let progress = (time * speed + seed)
                        .truncatingRemainder(dividingBy: 1.0)
                    
                    // Ease-in movement (accelerates inward)
                    let easedProgress = pow(progress, 1.6)
                    
                    let radius = outerRadius -
                    easedProgress * (outerRadius - coreRadius)
                    
                    let curl = sin(progress * .pi * 2 + seed) * curlStrength
                    
                    let x = center.x
                    + cos(angle) * radius
                    + cos(angle + .pi / 2) * curl
                    
                    let y = center.y
                    + sin(angle) * radius
                    + sin(angle + .pi / 2) * curl
                    
                    let alpha = pow(1.0 - progress, 1.8)
                    let particleSize = baseSize + easedProgress * sizeGrowth
                    
                    let color = Color(
                        hue: 0.58 + sin(seed) * 0.04,
                        saturation: 0.85,
                        brightness: 1.0,
                        opacity: alpha
                    )
                    
                    context.fill(
                        Path(ellipseIn: CGRect(
                            x: x - particleSize / 2,
                            y: y - particleSize / 2,
                            width: particleSize,
                            height: particleSize
                        )),
                        with: .color(color)
                    )
                }
                
                // MARK: - Core Glow
                let glowPath = Path(ellipseIn: CGRect(
                    x: center.x - coreRadius,
                    y: center.y - coreRadius,
                    width: coreRadius * 2,
                    height: coreRadius * 2
                ))
                
                context.fill(
                    glowPath,
                    with: .radialGradient(
                        Gradient(colors: [
                            Color.white.opacity(0.9),
                            Color.blue.opacity(0.35),
                            Color.clear
                        ]),
                        center: center,
                        startRadius: 2,
                        endRadius: coreRadius * 1.8
                    )
                )
            }
        }
        .frame(width: 200, height: 200)
    }
}
