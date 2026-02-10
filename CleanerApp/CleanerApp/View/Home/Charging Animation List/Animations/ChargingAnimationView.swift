//
//  ChargingAnimationView.swift
//  CleanerApp
//
//  Created by iMac on 05/01/26.
//

import SwiftUI

struct ChargingAnimationView: View {
    let animationType: ChargingAnimationType
    @StateObject var batteryMonitor = BatteryMonitor.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgDarkBlue.ignoresSafeArea()
                
                VStack {
                    switch animationType {
                    case .none: EmptyView()
                    case .waterDrop:
                        WaterDropChargingAnimationView()
                    case .bubbleRing:
                        BubbleRingAnimationView()
                    case .circularGlowingRing:
                        CircularGlowingRingChargingAnimationView()
                    case .circularNoiseRing:
                        CircularNoiseRingAnimationView()
                    case .angularGlowingRing:
                        AngularRingAnimationView()
                    case .rainDropBucket:
                        ChargingBucketView()
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .onAppear {
                if !batteryMonitor.isCharging {
                    AppState.shared.updateChargingState(isCharging: false)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        AppState.shared.showChargingAnimation = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}
