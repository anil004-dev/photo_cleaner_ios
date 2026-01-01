//
//  AllContactsView.swift
//  CleanerApp
//
//  Created by iMac on 15/12/25.
//

import SwiftUI

struct AllContactsView: View {
    
    @StateObject var viewModel = AllContactsViewModel()
    
    var body: some View {
        ZStack {
            LinearGradient.blueBg.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                allContactSection
            }
        }
        .navigationTitle("All Contacts")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            viewModel.onAppear()
        }
    }
    
    private var allContactSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            let arrContacts = viewModel.arrContacts
            
            if arrContacts.isEmpty {
                ContentUnavailableView(
                    "No Contacts",
                    systemImage: "person.crop.circle.badge.xmark",
                    description: Text(
                        "You don’t have any contacts yet. Add a contact or sync your contacts to see them here."
                    )
                )
            } else {
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack { }.frame(height: 5)
                        
                        ForEach(arrContacts) { contact in
                            contactRow(contact: contact)
                        }
                        
                        VStack { }.frame(height: 20)
                    }
                    .padding(.horizontal, 20)
                }
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
    }
}
