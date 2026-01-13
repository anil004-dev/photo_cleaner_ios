//
//  ChargingAnimationView.swift
//  CleanerApp
//
//  Created by iMac on 05/01/26.
//

import SwiftUI

struct ChargingAnimationPreviewCard: View {
    let animationType: ChargingAnimationType

    var body: some View {
        VStack {
            switch animationType {
            case .none: EmptyView()
            case .waterDrop:
                WaterDropChargingAnimationPreview()
            case .bubbleRing:
                BubbleRingAnimationPreview()
            case .circularGlowingRing:
                CircularGlowingRingChargingAnimationPreview()
            case .circularNoiseRing:
                CircularNoiseRingAnimationPreview()
            case .angularGlowingRing:
                AngularRingAnimationPreview()
            }
        }
    }
}

struct ChargingAnimationView: View {
    let animationType: ChargingAnimationType

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    switch animationType {
                    case .none: EmptyView()
                    case .waterDrop:
                        WaterDropChargingAnimationView()
                    case .bubbleRing:
                        BubbleRingAnimationPreview()
                    case .circularGlowingRing:
                        CircularGlowingRingChargingAnimationPreview()
                    case .circularNoiseRing:
                        CircularNoiseRingAnimationView()
                    case .angularGlowingRing:
                        AngularRingAnimationView()
                    }
                }
            }
            .onAppear {
                if !BatteryMonitor.shared.isCharging {
                    AppState.shared.showChargingAnimation = false
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
