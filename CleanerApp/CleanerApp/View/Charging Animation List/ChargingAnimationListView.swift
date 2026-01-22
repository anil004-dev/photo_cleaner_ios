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
            //LinearGradient.blueBg.ignoresSafeArea()
            Color.cnThemeBg.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                chargAnimationListSection
            }
        }
        .navigationTitle("Charging Animations")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
    }
    
    private var chargAnimationListSection: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.arrChargAnimations, id: \.id) { animation in
                    ChargingAnimationPreviewCard(animationType: animation.type)
                        .onTapGesture {
                            viewModel.openChargingAnimationPreviewScreen(animation: animation)
                        }
                }
            }
            .padding()
        }
    }
}

