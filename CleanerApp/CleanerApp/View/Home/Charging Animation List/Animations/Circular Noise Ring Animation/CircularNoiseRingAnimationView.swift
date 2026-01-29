//
//  CircularNoiseRingAnimationView.swift
//  ShaderEffects
//
//  Created by Grisha Tadevosyan on 16.11.24.
//

import SwiftUI

struct CircularNoiseRingAnimationPreview: View {
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            CircularNoiseRingAnimationView()
                .frame(height: 500)
                .padding([.top, .leading, .trailing])
        }
        .background(Color.black.ignoresSafeArea())
    }
}

struct CircularNoiseRingAnimationView: View {
    
    @StateObject var batteryMonitor = BatteryMonitor.shared
    @State var color: Color = .white
    let startDate = Date()
    var isPreview: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                if isPreview == false {
                    VStack(alignment: .center, spacing: 0) {
                        dateAndTimeSection
                        Spacer()
                    }
                }
                
                ringSection(geometry: geometry)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private var dateAndTimeSection: some View {
        VStack(alignment: .center, spacing: 4) {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                Text(Date(), style: .time)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                
                Text(Date(), style: .date)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
    
    private func ringSection(geometry: GeometryProxy) -> some View {
        ZStack {
            TimelineView(.animation) { _ in
                VStack {
                    color
                }
                .colorEffect(
                    ShaderLibrary.CircleLoaderEffect(
                        .float2(geometry.size),
                        .float(-startDate.timeIntervalSinceNow)
                    )
                )
                .scaleEffect(0.8)
            }
            
            CNText(title: "\(Int(batteryMonitor.level * 100))%", color: .white, font: .system(size: 20, weight: .bold, design: .default), alignment: .center)
        }
    }
}
