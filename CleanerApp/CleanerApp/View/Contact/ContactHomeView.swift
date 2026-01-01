//
//  ContactHomeView.swift
//  CleanerApp
//
//  Created by iMac on 09/12/25.
//

import SwiftUI

struct ContactHomeView: View {
    
    @StateObject var viewModel = ContactHomeViewModel()
    
    var body: some View {
        ZStack {
            LinearGradient.blueBg.ignoresSafeArea()
            //Color.cnThemeBg.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                contactHomeSection
            }
        }
        .navigationTitle("Contact Menu")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .onAppear {
            viewModel.onAppear()
        }
    }
    
    private var contactHomeSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.arrMenuSection) { menu in
                        menuSection(
                            section: menu,
                            onRowTap: { menu in
                                viewModel.btnMenuAction(menu: menu)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

extension ContactHomeView {
    
    @ViewBuilder private func menuSection(section: ContactSection, onRowTap: @escaping ((ContactMenu) -> Void)) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            CNText(title: section.title, color: .white, font: .system(size: 15, weight: .semibold, design: .default))
                .padding(.vertical, 15)
            
            VStack(alignment: .leading, spacing: 15) {
                ForEach(section.arrMenu) { menu in
                    menuRow(
                        menu: menu,
                        onTap: {
                            onRowTap(menu)
                        }
                    )
                }
            }
        }
    }
    
    @ViewBuilder private func menuRow(menu: ContactMenu, onTap: @escaping (() -> Void)) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 15) {
                    VStack(alignment: .leading, spacing: 10) {
                        CNText(title: menu.title, color: .white, font: .system(size: 17, weight: .semibold, design: .default))
                        
                        CNText(title: menu.subTitle, color: .white, font: .system(size: 14, weight: .regular, design: .default))
                    }
                    
                    Spacer(minLength: 0)
                    
                    HStack(alignment: .center, spacing: 5) {
                        CNText(title: "\(menu.contactCount)", color: .white, font: .system(size: 15, weight: .medium, design: .default), alignment: .trailing)
                        
                        Image(systemName: "chevron.right")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.white)
                            .frame(width: 20, height: 20)
                    }
                    
                }
            }
            .padding(15)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.darkBlueCellBg)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
            onTap()
        }
    }
}
