//
//  ChargingAnimationPreviewView.swift
//  CleanerApp
//
//  Created by iMac on 05/01/26.
//

import SwiftUI

struct ChargingAnimationPreviewView: View {
    
    @ObservedObject var viewModel: ChargingAnimationPreviewViewModel
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 15) {
                previewSection
            }
        }
        .ignoresSafeArea(edges: [.bottom])
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.applyAnimation()
                } label: {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            switch viewModel.chargingAnimation.type {
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
            }
        }
    }
}
