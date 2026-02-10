//
//  ChargingAnimationListView.swift
//  CleanerApp
//
//  Created by iMac on 05/01/26.
//

import SwiftUI

struct ChargingAnimationListView: View {
    
    @StateObject var viewModel = ChargingAnimationListViewModel()
    
    var body: some View {
        ZStack {
            LinearGradient.orangeBg.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                CNText(title: "Charging Animation", color: .txtBlack, font: .system(size: 24, weight: .bold, design: .default), alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 6)
                
                chargAnimationListSection
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private var chargAnimationListSection: some View {
        ScrollView {
            LazyVStack(alignment: .center, spacing: 18) {
                ForEach(viewModel.arrChargAnimations, id: \.id) { animation in
                    chargingAnimationRow(animation: animation)
                }
            }
            .padding(.vertical, 20)
        }
    }
    
    @ViewBuilder
    private func chargingAnimationRow(animation: ChargingAnimation) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    CNText(title: animation.name, color: .txtBlack, font: .system(size: 24, weight: .bold, design: .default), alignment: .leading)
                    
                    Spacer(minLength: 0)
                    
                    Button {
                        viewModel.openChargingAnimationPreviewScreen(animation: animation)
                    } label: {
                        HStack(alignment: .center, spacing: 0) {
                            CNText(title: "Try now", color: .txtBlack, font: .system(size: 18, weight: .medium, design: .default), alignment: .center)
                                .padding(.horizontal, 28)
                                .padding(.vertical, 12)
                        }
                        .background(Color(hex: "D8D8D8"))
                        .clipShape(Capsule())
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 0)
                
                VStack(alignment: .center, spacing: 0) {
                    chargingAnimationPreview(type: animation.type, width: 125, height: 140)
                }
                .frame(width: 125, height: 140)
            }
            .padding(15)
        }
        .frame(height: 170)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.primOrange, lineWidth: 2)
        )
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.primOrange)
                .offset(x: 4, y: 4)
        }
        .padding(.horizontal, 18)
    }
    
    @ViewBuilder
    private func chargingAnimationPreview(type: ChargingAnimationType, width: CGFloat, height: CGFloat) -> some View {
        VStack(alignment: .center, spacing: 0) {
            switch type {
            case .none:
                EmptyView()
            case .waterDrop:
                VStack(alignment: .center, spacing: 0) {
                    WaterDropChargingAnimationView()
                        .scaleEffect(0.38)
                }
                .frame(width: width, height: height)
            case .bubbleRing:
                VStack(alignment: .center, spacing: 0) {
                    BubbleRingAnimationView()
                        .scaleEffect(0.4)
                }
                .frame(width: width, height: height)
            case .circularGlowingRing:
                VStack(alignment: .center, spacing: 0) {
                    CircularGlowingRingChargingAnimationView()
                        .scaleEffect(0.4)
                }
                .frame(width: width, height: height)
            case .circularNoiseRing:
                VStack(alignment: .center, spacing: 0) {
                    CircularNoiseRingAnimationView(isPreview: true)
                }
                .frame(width: width, height: height)
            case .angularGlowingRing:
                VStack(alignment: .center, spacing: 0) {
                    AngularRingAnimationView(isPreview: true)
                        .offset(x: -38, y: -30)
                        .frame(width: width, height: height)
                        .scaleEffect(0.5)
                }
                .frame(width: width, height: height)
            case .rainDropBucket:
                VStack(alignment: .center, spacing: 0) {
                    ChargingBucketView()
                        .frame(width: width, height: height)
                        .scaleEffect(0.4)
                }
                .frame(width: width, height: height)
            }
        }
        .frame(width: width, height: height)
        .background(Color(hex: "101026"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
