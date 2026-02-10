//
//  SettingsView.swift
//  CleanerApp
//
//  Created by iMac on 30/01/26.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject var viewModel = SettingsViewModel()
    
    var body: some View {
        ZStack {
            LinearGradient.orangeBg.ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 0) {
                ScrollView(.vertical) {
                    VStack(alignment: .center, spacing: 0) {
                        settingsSection
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .toolbarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showShareAppView) {
            if let url = URL(string: CNConstant.appURL) {
                CNShareSheetView(items: [url])
                    .presentationDetents([.medium, .large])
            }
        }
    }
    
    private var settingsSection: some View {
        VStack(alignment: .center, spacing: 15) {
            ForEach(viewModel.arrSection) { section in
                settingSection(section: section)
            }
        }
    }
    
    @ViewBuilder
    private func settingSection(section: SettingSection) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(section.arrOption.indices, id: \.self) { index in
                let option = section.arrOption[index]
                settingOptions(option: option, showSeparator: index+1 != section.arrOption.count)
            }
        }
        .padding(.vertical, 3)
        .background(Color(hex: "FDFDFD"))
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .padding(.horizontal, 23)
    }
    
    @ViewBuilder
    private func settingOptions(option: SettingOption, showSeparator: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 8) {
                Image(option.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 46, height: 46)
                
                CNText(title: option.title, color: .txtBlack, font: .system(size: 17, weight: .semibold, design: .default), alignment: .leading)
                
                Spacer(minLength: 0)
                
                Image(systemName: "chevron.forward")
                    .resizable()
                    .scaledToFit()
                    .fontWeight(.bold)
                    .foregroundStyle(Color.txtBlack)
                    .frame(width: 11, height: 16)
            }
            .padding(.leading, 14)
            .padding(.trailing, 20)
            .padding(.vertical, 10)
            
            if showSeparator {
                Rectangle()
                    .fill(Color(hex: "F0F0F0"))
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 14)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "FDFDFD"))
        .onTapGesture {
            viewModel.btnOptionAction(option: option)
        }
    }
}

#Preview {
    SettingsView()
}
