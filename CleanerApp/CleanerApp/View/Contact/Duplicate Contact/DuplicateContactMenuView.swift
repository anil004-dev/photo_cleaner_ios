//
//  DuplicateContactMenuView.swift
//  CleanerApp
//
//  Created by iMac on 09/12/25.
//

import SwiftUI

struct DuplicateContactMenuView: View {
    
    @ObservedObject var viewModel: DuplicateContactMenuViewModel
    
    var body: some View {
        ZStack {
            Color.cnThemeBg.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                duplicateContactSection
            }
        }
        .navigationTitle("Duplicates")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }
    
    private var duplicateContactSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            CNText(title: "Duplicates", color: .white, font: .title2)
                .padding(.top, 15)
            
            ForEach(viewModel.arrDuplicateMenu) { duplicateContact in
                duplicateRow(
                    menu: duplicateContact,
                    onTap: {
                        viewModel.btnMenuRow(duplicateContact: duplicateContact)
                    }
                )
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private func duplicateRow(menu: DuplicateContact, onTap: @escaping (() -> Void)) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 15) {
                        CNText(title: menu.title, color: .white, font: .system(size: 17, weight: .semibold, design: .default))
                    
                    Spacer(minLength: 0)
                    
                    HStack(alignment: .center, spacing: 5) {
                        CNText(title: "\(menu.arrContactGroup.count)", color: .white, font: .system(size: 15, weight: .medium, design: .default), alignment: .trailing)
                        
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
