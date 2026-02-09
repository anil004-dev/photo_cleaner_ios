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
            Color.bgDarkBlue.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                CNText(title: "Charging Animation", color: .white, font: .system(size: 24, weight: .bold, design: .default), alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 6)
                
                chargAnimationListSection
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private var chargAnimationListSection: some View {
        ScrollView {
            let totalHorizontalPadding: CGFloat = 17 * 2
            let itemSpacing: CGFloat = 10
            let numberOfColumns: CGFloat = 2
            let availableWidth = UIScreen.main.bounds.width - totalHorizontalPadding - (itemSpacing * (numberOfColumns - 1))
            let width = availableWidth / numberOfColumns
            let height = width * 1.5
            let columns = Array(
                repeating: GridItem(.fixed(width), spacing: itemSpacing),
                count: Int(numberOfColumns)
            )
            
            LazyVGrid(columns: columns, spacing: itemSpacing) {
                ForEach(viewModel.arrChargAnimations, id: \.id) { animation in
                    chargingAnimationPreview(type: animation.type, width: width, height: height)
                        .onTapGesture {
                            viewModel.openChargingAnimationPreviewScreen(animation: animation)
                        }
                }
            }
            .padding()
        }
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
                        .scaleEffect(0.7)
                }
                .frame(width: width, height: height)
            case .bubbleRing:
                VStack(alignment: .center, spacing: 0) {
                    BubbleRingAnimationView()
                        .scaleEffect(0.7)
                }
                .frame(width: width, height: height)
            case .circularGlowingRing:
                VStack(alignment: .center, spacing: 0) {
                    CircularGlowingRingChargingAnimationView()
                        .scaleEffect(0.7)
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
                        .frame(width: width, height: height)
                        .scaleEffect(0.7)
                }
                .frame(width: width, height: height)
            case .rainDropBucket:
                VStack(alignment: .center, spacing: 0) {
                    ChargingBucketView()
                        .frame(width: width, height: height)
                        .scaleEffect(0.7)
                }
                .frame(width: width, height: height)
            }
        }
        .frame(width: width, height: height)
        .background(Color(hex: "101026"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
