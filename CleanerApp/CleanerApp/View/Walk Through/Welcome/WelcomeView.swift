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
            LinearGradient.blueBg.ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 0) {
                welcomeSection
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private var welcomeSection: some View {
        VStack(alignment: .center, spacing: 0) {
            CNText(title: "Welcome to\nCleanup storage\nmaster", color: .white, font: .system(size: 36, weight: .bold, design: .default), alignment: .center)
                .padding(.top, 30)
            
            Spacer()
            
            Image(.imgPhotos)
                .resizable()
                .scaledToFit()
                .frame(width: 211, height: 152)
                .padding(.bottom, 30)
                        
            Spacer()
            
            CNText(title: "Cleaner AI requires access to your Photos to help free up storage. We value transparency and are committed to protecting your privacy.", color: .white, font: .system(size: 14, weight: .regular, design: .default), alignment: .center)
                .padding(.horizontal, 36)
                .padding(.bottom, 33)
            
            CNButton(title: "Get Started", onTap: viewModel.btnGetStartedAction)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
    }
}
