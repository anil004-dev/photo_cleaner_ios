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
            Color.bgDarkBlue.ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 0) {
                ScrollView(.vertical) {
                    VStack(alignment: .center, spacing: 25) {
                        settingsSection
                        supportSection
                        
                        CNText(title: Utility.appVersionString(), color: Color(hex: "7F818D"), font: .system(size: 12, weight: .regular, design: .default))
                    }
                    .padding(20)
                }
            }
        }
        .navigationTitle("Settings")
        .toolbarTitleDisplayMode(.large)
        .sheet(isPresented: $viewModel.showShareAppView) {
            if let url = URL(string: CNConstant.appURL) {
                CNShareSheetView(items: [url])
                    .presentationDetents([.medium, .large])
            }
        }
    }
    
    private var settingsSection: some View {
        VStack(alignment: .center, spacing: 25) {
            ForEach(viewModel.arrSection) { section in
                settingSection(section: section)
            }
        }
    }
    
    private var supportSection: some View {
        VStack(alignment: .center, spacing: 10) {
            let section = viewModel.supportSection
            
            CNText(title: section.title, color: Color(hex: "7F818D"), font: .system(size: 16, weight: .regular, design: .default), alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
            
            VStack(alignment: .leading, spacing: 0) {
                ForEach(0..<section.arrOption.count, id: \.self) { index in
                    let option = section.arrOption[index]
                    supportOptions(option: option, showSeparator: (index+1) != section.arrOption.count)
                }
            }
            .background(Color(hex: "191D2B"))
            .clipShape(RoundedRectangle(cornerRadius: 26))
        }
    }
    
    @ViewBuilder
    private func settingSection(section: SettingSection) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            CNText(title: section.title, color: Color(hex: "7F818D"), font: .system(size: 16, weight: .regular, design: .default), alignment: .leading)
                .padding(.horizontal, 10)
            
            ForEach(section.arrOption) { option in
                settingOptions(option: option)
            }
        }
    }
    
    @ViewBuilder
    private func settingOptions(option: SettingOption) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: option.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                
                VStack(alignment: .leading, spacing: 5) {
                    CNText(title: option.title, color: .white, font: .system(size: 18, weight: .bold, design: .default), alignment: .leading)
                    
                    CNText(title: option.subTitle, color: Color(hex: "7F818D"), font: .system(size: 12, weight: .regular, design: .default), alignment: .leading)
                }
                
                Spacer(minLength: 0)
                
                Image(systemName: "chevron.forward")
                    .resizable()
                    .scaledToFit()
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: "9395A2"))
                    .frame(width: 11, height: 16)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "191D2B"))
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .onTapGesture {
            viewModel.btnOptionAction(option: option)
        }
    }
    
    @ViewBuilder
    private func supportOptions(option: SettingOption, showSeparator: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: option.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 26)
                
                CNText(title: option.title, color: .white, font: .system(size: 16, weight: .semibold, design: .default), alignment: .leading)
                
                Spacer(minLength: 0)
                
                Image(systemName: "chevron.forward")
                    .resizable()
                    .scaledToFit()
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: "9395A2"))
                    .frame(width: 10, height: 15)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            if showSeparator {
                Rectangle()
                    .fill(Color(hex: "282C39"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
            }
        }
        .onTapGesture {
            viewModel.btnOptionAction(option: option)
        }
    }
}

#Preview {
    SettingsView()
}
