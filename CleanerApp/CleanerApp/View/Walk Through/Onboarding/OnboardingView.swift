//
//  OnboardingView.swift
//  CleanerApp
//
//  Created by iMac on 23/01/26.
//

import SwiftUI

struct OnboardingView: View {
    
    @StateObject var viewModel = OnboardingViewModel()
    @EnvironmentObject var mediaDatabase: MediaDatabase
    
    var body: some View {
        ZStack {
            LinearGradient.orangeBg.ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 0) {
                onboardingSection
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            mediaDatabase.startScan()
            viewModel.onAppear()
        }
    }
    
    private var onboardingSection: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(alignment: .center, spacing: 6) {
                HStack(spacing: 8) {
                    ForEach(0..<viewModel.arrSteps.count, id: \.self) { index in
                        ProgressView(value: viewModel.progressValues[index])
                            .tint(Color.primOrange)
                            .progressViewStyle(.linear)
                            .frame(height: 4)
                            .animation(.linear(duration: 0.1), value: viewModel.progressValues[index])
                    }
                    
                    Button {
                        viewModel.moveToHomeScreen()
                    } label: {
                        CNText(title: "Skip", color: .txtBlack, font: .system(size: 16, weight: .medium, design: .default), alignment: .center)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 10)
            
            let step = viewModel.arrSteps[viewModel.currentIndex]
            
            Spacer()
            
            Image(step.image)
                .resizable()
                .scaledToFit()
                .frame(height: 300)
                .frame(maxWidth: .infinity)
                .id(viewModel.currentIndex)
                .transition(
                    .asymmetric(
                        insertion: .scale(scale: 0.85).combined(with: .opacity),
                        removal: .scale(scale: 1.1).combined(with: .opacity)
                    )
                )
                .animation(.easeInOut(duration: 0.4), value: viewModel.currentIndex)
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
                .offset(x: 10)
            
            GeometryReader { proxy  in
                ScrollViewReader { scrollViewProxy in
                    ScrollView(.horizontal) {
                        HStack(alignment: .top, spacing: 0) {
                            ForEach(0..<viewModel.arrSteps.count, id: \.self) { index in
                                let step = viewModel.arrSteps[index]
                                
                                VStack(alignment: .center, spacing: 13) {
                                    CNText(title: step.title, color: .txtBlack, font: .custom("YoungSerif-Regular", size: 29), alignment: .center, lineLimit: 3)
                                    
                                    CNText(title: step.description, color: .txtBlack, font: .system(size: 16, weight: .regular, design: .default), alignment: .center, lineLimit: 2)
                                        .frame(height: 45)
                                        .padding(.horizontal, 35)
                                }
                                .id(index)
                                .frame(width: proxy.size.width)
                            }
                        }
                        .onChange(of: viewModel.currentIndex) { _, newValue in
                            withAnimation {
                                scrollViewProxy.scrollTo(newValue, anchor: .center)
                            }
                        }
                    }
                }
            }
            .disabled(true)
            .frame(height: 170)
            .padding(.bottom, 80)

            CNButton(title: "CONTINUE", height: 58, onTap: viewModel.btnContinueAction)
                .clipShape(RoundedRectangle(cornerRadius: 29))
                .padding(.horizontal, 26)
                .padding(.bottom, 20)
        }
    }
}
