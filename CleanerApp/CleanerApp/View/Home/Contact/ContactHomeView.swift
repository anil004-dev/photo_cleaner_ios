//
//  ContactHomeView.swift
//  CleanerApp
//
//  Created by iMac on 09/12/25.
//

import SwiftUI

struct ContactHomeView: View {
    
    @StateObject var viewModel = ContactHomeViewModel()
    @Environment(\.modelContext) var context
    
    var body: some View {
        ZStack {
            Color.bgDarkBlue.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                contactHomeSection
            }
        }
        .navigationTitle("Contact Cleaner")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .onAppear {
            ContactBackupManager.shared.configure(with: context)
            viewModel.onAppear()
        }
    }
    
    private var contactHomeSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let showPermissionSection = viewModel.showPermissionSection {
                if showPermissionSection {
                    permissionSection
                } else {
                    contactMenuSection
                }
            }
        }
    }
    
    private var permissionSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .center, spacing: 0) {
                Spacer()
                
                Image(.imgContactPermission)
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 10)
                    .padding(.bottom, 96)
                
                CNText(title: "Need Access to Your Contacts", color: .white, font: .system(size: 24, weight: .bold, design: .default), alignment: .center)
                    .padding(.bottom, 8)
                
                CNText(title: "Cleaner AI requires contact access to\nwork properly. You can enable this in\nSettings.", color: .white, font: .system(size: 17, weight: .regular, design: .default), alignment: .center)
                    .padding(.bottom, 30)
                
                CNButton(title: "Go to Settings") {
                    viewModel.btnGoToSettingsAction()
                }
                .padding(.bottom, 30)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
        }
    }
    
    private var contactMenuSection: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.arrContactMenu) { menu in
                    menuRow(
                        menu: menu,
                        onTap: {
                            viewModel.btnMenuAction(menu: menu)
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

extension ContactHomeView {
    
    
    @ViewBuilder private func menuRow(menu: ContactMenu, onTap: @escaping (() -> Void)) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 15) {
                Image(menu.imageName)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                
                VStack(alignment: .leading, spacing: 5) {
                    CNText(title: menu.title, color: .white, font: .system(size: 20, weight: .semibold, design: .default))
                    
                    CNText(title: menu.subTitle, color: .white, font: .system(size: 13, weight: .regular, design: .default))
                }
                .padding(.vertical, 18)
                
                Spacer(minLength: 0)
                
                Image(systemName: "chevron.right")
                    .resizable()
                    .scaledToFit()
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: "EBEBF5").opacity(0.6))
                    .frame(width: 11, height: 16)
            }
            .padding(.horizontal, 18)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.darkBlueCellBg)
        .clipShape(RoundedRectangle(cornerRadius: 21))
        .onTapGesture {
            onTap()
        }
    }
}
