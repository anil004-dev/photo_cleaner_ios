//
//  IncompleteContactMenuView.swift
//  CleanerApp
//
//  Created by iMac on 10/12/25.
//

import SwiftUI

struct IncompleteContactMenuView: View {
    
    @ObservedObject var viewModel: IncompleteContactMenuViewModel
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                incompleteContactSection
            }
        }
        .navigationTitle("Incomplete")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }
    
    private var incompleteContactSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            CNText(title: "Incomplete", color: .white, font: .title2)
                .padding(.top, 15)
            
            ForEach(viewModel.arrIncompleteMenu) { incompleteContact in
                incompleteRow(
                    menu: incompleteContact,
                    onTap: {
                        viewModel.btnMenuRow(incompleteContact: incompleteContact)
                    }
                )
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private func incompleteRow(menu: IncompleteContact, onTap: @escaping (() -> Void)) -> some View {
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
