//
//  CircularGlowingRingChargingAnimationView.swift
//  CleanerApp
//
//  Created by iMac on 09/01/26.
//

import Foundation
import SwiftUI
import Combine

struct CircularGlowingRingChargingAnimationPreview: View {
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            CircularGlowingRingChargingAnimationView(isForPreview: true)
                .frame(height: 500)
                .padding([.top, .leading, .trailing])
        }
        .background(Color.black.ignoresSafeArea())
    }
}

// MARK: - Main CircularRing Charging Animation View
struct CircularGlowingRingChargingAnimationView: View {
    
    @State private var animate = false
    @StateObject var batteryMonitor = BatteryMonitor.shared
    var isForPreview: Bool = false
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center, spacing: 0) {
                dateAndTimeSection
                Spacer()
            }
            
            ringSection
                .padding(.top, isForPreview ? 80 : 0)
        }
    }
    
    private var dateAndTimeSection: some View {
        VStack(alignment: .center, spacing: 4) {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                VStack(spacing: 4) {
                    Text(context.date, style: .time)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)

                    Text(context.date, style: .date)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding(.top, 50)
    }
    
    private var ringSection: some View {
        ZStack {
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.orange, .yellow, .green, .cyan, .blue, .purple]),
                        startPoint: UnitPoint(x: animate ? 0.5 : -1, y: animate ? 0.5 : -0.5),
                        endPoint: UnitPoint(x: animate ? 2 : 0.5, y: animate ? 1.5 : 0.5)
                    ),
                    lineWidth: 12
                )
                .frame(width: 200, height: 200)
                .blur(radius: 20)
                .shadow(color: .yellow, radius: 16, x: 0, y: 0)
            
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.orange, .yellow, .green, .cyan, .blue, .purple]),
                        startPoint: UnitPoint(x: animate ? 0.5 : -1, y: animate ? 0.5 : -0.5),
                        endPoint: UnitPoint(x: animate ? 2 : 0.5, y: animate ? 1.5 : 0.5)
                    ),
                    lineWidth: 5
                )
                .frame(width: 200, height: 200)
                .onAppear {
                    withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: true)) {
                        animate = true
                    }
                }
            
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black, Color(white: 0.15)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 200, height: 200)
            
            CNText(title: "\(Int(batteryMonitor.level * 100))%", color: .white, font: .system(size: 20, weight: .bold, design: .default), alignment: .center)
            
            RingParticleEmitter(ringRadius: 100)
        }
    }
}



struct RingParticle: Identifiable {
    let id = UUID()
    let angle: Double
    let radius: CGFloat
    let size: CGFloat
}

struct RingParticleView: View {
    let particle: RingParticle
    let baseRadius: CGFloat
    
    @State private var progress: CGFloat = 0
    
    var body: some View {
        let x = cos(particle.angle) * (baseRadius + progress)
        let y = sin(particle.angle) * (baseRadius + progress)
        
        Circle()
            .fill([.orange, .yellow, .green, .cyan, .blue, .red, .pink, .indigo].randomElement() ?? .yellow)
            .frame(width: particle.size, height: particle.size)
            .offset(x: x, y: y)
            .opacity(Double(max(0, 1.0 - (progress / 30.0))))
            .scaleEffect(1 - progress / 40)
            .onAppear {
                withAnimation(.easeOut(duration: 1.2)) {
                    progress = 40
                }
            }
    }
}

struct RingParticleEmitter: View {
    
    let ringRadius: CGFloat
    @State private var particles: [RingParticle] = []
    private let paritcleSpawnTimer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                RingParticleView(
                    particle: particle,
                    baseRadius: ringRadius
                )
            }
        }
        .frame(width: ringRadius * 2.6, height: ringRadius * 2.6)
        .onReceive(paritcleSpawnTimer) { _ in
            startSpawnningParticle()
        }
    }
    
    private func startSpawnningParticle() {
        let particle = RingParticle(
            angle: Double.random(in: 0...(2 * .pi)),
            radius: ringRadius,
            size: CGFloat.random(in: 3...6)
        )
        
        particles.append(particle)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            particles.removeAll { $0.id == particle.id }
        }
    }
}

