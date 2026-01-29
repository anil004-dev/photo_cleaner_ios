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
            Color.bgDarkBlue.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                duplicateContactGroupSection
            }
        }
        .toolbar(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                let isAllSelected = viewModel.duplicateContact.arrContactGroup.allSatisfy({ $0.isAllSelected })
                
                Button {
                    if !isAllSelected  {
                        viewModel.btnSelectAllAction()
                    } else {
                        viewModel.btnDeselectAllAction()
                    }
                } label: {
                    HStack(alignment: .center, spacing: 5) {
                        Image(.icSqaureCheckmark)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                        
                        CNText(title: isAllSelected ? "Deselect All" : "Select All", color: .white, font: .system(size: 17, weight: .medium, design: .default), alignment: .center)
                    }
                    .padding(.horizontal, 10)
                    .clipShape(Rectangle())
                }
            }
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            CNText(title: "Duplicates", color: .white, font: .system(size: 34, weight: .bold, design: .default), alignment: .trailing)
            
            CNText(title: "\(viewModel.duplicateContact.contactCount) Contacts", color: .init(hex: "7E828B"), font: .system(size: 12, weight: .semibold, design: .default), alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }
    
    private var duplicateContactGroupSection: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                titleSection
                    .padding(.bottom, 8)
                
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(viewModel.duplicateContact.arrContactGroup) { contactGroup in
                            contactGroupRow(group: contactGroup)
                        }
                    }
                    .padding(20)
                }
                .transition(.move(edge: .bottom))
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !viewModel.arrContactGroupToMerge.isEmpty {
                previewButton
            }
        }
        .animation(.easeInOut, value: viewModel.arrContactGroupToMerge.isEmpty)
    }
    
    private var previewButton: some View {
        VStack(alignment: .center, spacing: 0) {
            Button {
                viewModel.openPreviewScreen()
            } label: {
                HStack(alignment: .center, spacing: 11) {
                    Spacer()
                    
                    Image(systemName: "arrow.trianglehead.merge")
                        .resizable()
                        .scaledToFit()
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(width: 15, height: 20)
                    
                    CNText(title: "Merge Preview (\(viewModel.arrContactGroupToMerge.count))", color: .white, font: .system(size: 18, weight: .semibold, design: .default), alignment: .center)
                    
                    Spacer()
                }
                .frame(height: 58)
                .background(Color.btnBlue)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(16)
            .disabled(!viewModel.isMergeButtonEnable)
            .opacity(viewModel.isMergeButtonEnable ? 1 : 0.7)
        }
        .ifiOS26Unavailable { view in
            view
                .background(Color(hex: "232531"))
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .ifiOS26Available { view in
            if #available(iOS 26.0, *) {
                view
                    .background(Color(hex: "232531").opacity(0.5))
                    .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 20))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
        .padding(.horizontal, 10)
        .transition(.move(edge: .bottom))
        .animation(.easeInOut, value: viewModel.arrContactGroupToMerge.isEmpty)
    }
}

extension DuplicateContactGroupView {
    
    @ViewBuilder private func contactGroupRow(group: ContactGroup) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 0) {
                CNText(title: "\(group.arrContacts.count) Duplicate Contacts", color: .white, font: .system(size: 20, weight: .medium, design: .default), alignment: .trailing)
                
                Spacer(minLength: 10)
                
                let isAllSelected = group.arrContacts.allSatisfy({ $0.isSelected })
                Button {
                    if !isAllSelected {
                        viewModel.btnSelectAll(contactGroup: group)
                    } else {
                        viewModel.btnDeselectAll(contactGroup: group)
                    }
                } label: {
                    CNText(title: isAllSelected ? "Deselect All" : "Select All", color: .btnBlue, font: .system(size: 17, weight: .regular, design: .default), alignment: .trailing)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(group.arrContacts) { contact in
                        contactRow(contact: contact)
                    }
                }
                .padding(20)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.darkBlueCellBg)
            .clipShape(RoundedRectangle(cornerRadius: 36))
        }
    }
    
    @ViewBuilder private func contactRow(contact: ContactModel) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    CNText(title: contact.displayName ?? "No Name", color: .white, font: .system(size: 17, weight: .medium, design: .default))
                    
                    CNText(title: contact.phoneNumbers.first ?? "-", color: Color(hex: "7F818D"), font: .system(size: 18, weight: .regular, design: .default))
                }
                
                Spacer(minLength: 0)
                
                let isSelected = contact.isSelected
                
                Button {
                    viewModel.selectContact(contact: contact)
                } label: {
                    Image(isSelected ? .icSquareChecked : .icSquareUnchecked)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(isSelected ? .blue : .white)
                        .frame(width: 26, height: 26)
                        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 0)
                        .animation(.easeInOut(duration: 0.1), value: isSelected)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
        }
        .background(Color(hex: "191D2B"))
        .clipShape(RoundedRectangle(cornerRadius: 26))
    }
}

