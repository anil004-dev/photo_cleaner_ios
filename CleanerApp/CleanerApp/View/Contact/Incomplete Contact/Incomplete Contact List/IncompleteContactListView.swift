//
//  IncompleteContactListView.swift
//  CleanerApp
//
//  Created by iMac on 10/12/25.
//

import SwiftUI

struct IncompleteContactListView: View {
    
    @ObservedObject var viewModel: IncompleteContactListViewModel
    
    var body: some View {
        ZStack {
            Color.cnThemeBg.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                incompleteContactListSection
            }
        }
        .navigationTitle(viewModel.incompleteContact.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            viewModel.updateContact()
            
            if viewModel.incompleteContact.arrContactGroup.isEmpty {
                NavigationManager.shared.pop()
            }
        }
    }
    
    private var incompleteContactListSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(viewModel.incompleteContact.arrContactGroup) { contactGroup in
                        ForEach(contactGroup.arrContacts) { contact in
                            contactRow(contact: contact)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    @ViewBuilder private func contactRow(contact: ContactModel) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 10) {
                    CNText(title: contact.displayName ?? "-", color: .white, font: .system(size: 15, weight: .medium, design: .default))
                    
                    CNText(title: contact.phoneNumbers.first ?? "-", color: .gray, font: .system(size: 15, weight: .medium, design: .default))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(10)
        }
        .background(Color.darkBlueCellBg)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.clear)
                .stroke(Color.gray, lineWidth: 1)
        }
        .onTapGesture {
            viewModel.openEditContactView(contact: contact)
        }
    }
}
