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
                applyButton
            }
        }
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            switch viewModel.chargingAnimation.type {
            case .waterDrop:
                WaterDropChargingAnimationView()
            default:
                EmptyView()
            }
        }
    }
    
    private var applyButton: some View {
        VStack(alignment: .leading, spacing: 0) {
            CNButton(title: "Apply", height: 55) {
                viewModel.applyAnimation()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}
