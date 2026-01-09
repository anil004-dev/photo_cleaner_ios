//
//  ChargingAnimationPreviewCard.swift
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
            case .circularRing:
                CircularRingChargingAnimationPreview()
            case .circularGlowingRing:
                CircularGlowingAnimationPreview()
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
                    case .circularRing:
                        CircularRingChargingAnimationView()
                    case .circularGlowingRing:
                        CircularGlowingAnimationView()
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
