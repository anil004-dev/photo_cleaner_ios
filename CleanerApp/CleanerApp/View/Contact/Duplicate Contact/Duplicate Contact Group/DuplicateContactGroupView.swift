//
//  DuplicateContactGroupView.swift
//  CleanerApp
//
//  Created by iMac on 09/12/25.
//

import SwiftUI
import Combine

struct DuplicateContactGroupView: View {
    @ObservedObject var viewModel: DuplicateContactGroupViewModel
    
    var body: some View {
        ZStack {
            Color.cnThemeBg.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                duplicateContactGroupSection
            }
        }
        .navigationTitle(viewModel.duplicateContact.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }
    
    private var duplicateContactGroupSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(viewModel.duplicateContact.arrContactGroup) { contactGroup in
                        contactGroupRow(group: contactGroup)
                    }
                }
                .padding(20)
            }
            
            VStack(alignment: .center, spacing: 0) {
                CNButton(title: "Merge \(viewModel.contactToMergeCount)") {
                    viewModel.openPreviewScreen()
                }
                .opacity(viewModel.isMergeButtonEnable ? 1 : 0.5)
                .disabled(!viewModel.isMergeButtonEnable)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 15)
        }
    }
}

extension DuplicateContactGroupView {
    
    @ViewBuilder private func contactGroupRow(group: ContactGroup) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                CNText(title: "\(group.arrContacts.count) Duplicate Contacts", color: .white, font: .system(size: 15, weight: .medium, design: .default), alignment: .trailing)
                    .padding(.vertical, 10)
                
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(group.arrContacts) { contact in
                        contactRow(contact: contact)
                    }
                }
            }
            .padding(15)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.darkBlueCellBg)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    @ViewBuilder private func contactRow(contact: ContactModel) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 10) {
                    CNText(title: contact.displayName ?? "No Name", color: .white, font: .system(size: 15, weight: .medium, design: .default))
                    
                    CNText(title: contact.phoneNumbers.first ?? "-", color: .gray, font: .system(size: 15, weight: .medium, design: .default))
                }
                
                Spacer(minLength: 0)
                
                let isSelected = contact.isSelected
                
                Button {
                    viewModel.selectContact(contact: contact)
                } label: {
                    Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(isSelected ? .blue : .white)
                        .frame(width: 20, height: 20)
                }
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

