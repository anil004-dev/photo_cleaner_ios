//
//  BubbleRingAnimationView.swift
//  CleanerApp
//
//  Created by iMac on 08/01/26.
//

import SwiftUI
import Combine

struct BubbleRingAnimationPreview: View {
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            BubbleRingAnimationView()
                .frame(height: 500)
                .padding([.top, .leading, .trailing])
        }
        .background(Color.black.ignoresSafeArea())
    }
}

// MARK: - Main Charging Animation View
struct BubbleRingAnimationView: View {
    @StateObject var batteryMonitor = BatteryMonitor.shared

    var body: some View {
        ZStack(alignment: .center) {

            VStack(spacing: 0) {
                ZStack {
                    BatteryTextView(level: batteryMonitor.level)
                        .zIndex(0)
                    BubbleRingingView()
                        .zIndex(100)
                }
                .frame(width: 220, height: 220)

                RisingBubblesView(batteryMonitor: batteryMonitor)
            }
        }
    }
}

struct BatteryTextView: View {
    let level: CGFloat

    var body: some View {
        VStack(spacing: 6) {
            Text("\(Int(level * 100))%")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)

            Image(systemName: "bolt.fill")
                .foregroundColor(.cyan)
        }
    }
}

struct BubbleRingingView: View {

    var body: some View {
        Circle()
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: [
                        Color.cyan,
                        Color.blue,
                        Color.cyan
                    ]),
                    center: .center
                ),
                lineWidth: 10
            )
            .overlay(
                Circle()
                    .stroke(Color.cyan.opacity(0.6), lineWidth: 2)
                    .blur(radius: 6)
            )
            .rotationEffect(.degrees(true ? 360 : 0))
            .animation(
                .linear(duration: 6).repeatForever(autoreverses: false),
                value: true
            )
    }
}

import SwiftUI

struct Bubble: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
}

struct RisingBubblesView: View {
    @State private var bubbles: [Bubble] = []
    @ObservedObject var batteryMonitor: BatteryMonitor
    
    private let minSize: CGFloat = 5
    private let maxSize: CGFloat = 5
    private let horizontalSpread: CGFloat = 20
    private let columns = 5
    private let horizontalSpacing: CGFloat = 10
    private let verticalSpacing: CGFloat = 30
    private let bubbleSpawnTimer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(bubbles) { bubble in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.cyan, .cyan.opacity(0.3)],
                                center: .center,
                                startRadius: 1,
                                endRadius: bubble.size
                            )
                        )
                        .frame(width: bubble.size, height: bubble.size)
                        .position(x: bubble.x, y: bubble.y)
                }
            }
            .onReceive(bubbleSpawnTimer) { _ in
                if batteryMonitor.level != 1 {
                    spawnBubble(in: geo.size)
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func spawnBubble(in size: CGSize) {
        let column = Int.random(in: 0..<columns)
        let startX = size.width / 2 + CGFloat(column - columns / 2) * horizontalSpacing
        let startY = size.height
        
        let bubble = Bubble(
            x: startX,
            y: startY,
            size: CGFloat.random(in: minSize...maxSize)
        )
        
        let id = bubble.id
        bubbles.append(bubble)
        
        withAnimation(.easeInOut(duration: 2)) {
            if let index = bubbles.firstIndex(where: { $0.id == id }) {
                bubbles[index].y = 0
            }
        } completion: {
            withAnimation {
                bubbles.removeAll { $0.id == id }
            }
        }
    }
}
