//
//  WelcomeVC.swift
//  CleanerApp
//
//  Created by iMac on 23/01/26.
//

import SwiftUI

struct WelcomeView: View {
    
    @StateObject var viewModel = WelcomeViewModel()
    
    var body: some View {
        ZStack {
            LinearGradient.orangeBg.ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 0) {
                welcomeSection
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private var welcomeSection: some View {
        VStack(alignment: .center, spacing: 0) {
            
            Spacer()
            
            Image(.imgPhotos)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 35)
                .padding(.bottom, 40)
            
            CNText(title: "We’re so delighted\nyou are here!", color: .txtBlack, font: .custom("YoungSerif-Regular", size: 29), alignment: .center)
                .padding(.bottom, 20)
            
            
            CNText(title: "We requires access to your Photos to help free up storage. We value transparency and are committed to protecting your privacy.", color: .txtBlack, font: .system(size: 16, weight: .regular, design: .default), alignment: .center)
                .padding(.horizontal, 18)
                .padding(.bottom, 50)
            
            Button {
                viewModel.btnGetStartedAction()
            } label: {
                HStack(alignment: .center, spacing: 0) {
                    Image(systemName: "chevron.forward")
                        .resizable()
                        .scaledToFit()
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(width: 14, height: 23)
                        .padding(.leading, 2)
                }
                .frame(width: 70, height: 70)
                .background(Color.primOrange)
                .clipShape(Circle())
                .background {
                    Circle()
                        .fill(Color.primOrange.opacity(0.1))
                        .frame(width: 90, height: 90)
                }
            }
            .frame(width: 90, height: 90)
            .clipShape(Circle())
            .padding(.bottom, 20)
        }
    }
}
