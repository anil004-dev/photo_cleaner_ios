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
            Color.bgDarkBlue.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                incompleteContactListSection
            }
        }
        .toolbar(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                let isAllSelected =
                    !viewModel.incompleteContact.arrContacts.isEmpty &&
                    viewModel.arrContactToDelete.count ==
                    viewModel.incompleteContact.arrContacts.count
                
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
        .sheet(isPresented: $viewModel.showEditContactView.sheet) {
            if let contact = viewModel.showEditContactView.contact {
                CNContactEditView(
                    contact: contact,
                    onComplete: { contact in
                        viewModel.contactUpdated(contact: contact)
                    }
                )
            }
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            CNText(title: "Incomplete", color: .white, font: .system(size: 34, weight: .bold, design: .default), alignment: .trailing)
            
            CNText(title: "\(viewModel.incompleteContact.contactCount) Contacts", color: .init(hex: "7E828B"), font: .system(size: 12, weight: .semibold, design: .default), alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }
    
    private var incompleteContactListSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleSection
                .padding(.bottom, 8)
            
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.incompleteContact.arrContacts) { contact in
                        contactRow(contact: contact)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
                .padding(.top, 14)
            }
            .id(viewModel.refreshId)
            
            VStack(alignment: .center, spacing: 0) {
                Button {
                    viewModel.btnDeleteAction()
                } label: {
                    HStack(alignment: .center, spacing: 11) {
                        Spacer()
                        
                        Image(systemName: "trash.fill")
                            .resizable()
                            .scaledToFit()
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(width: 18, height: 21)
                        
                        CNText(title: "Delete Selected (\(viewModel.arrContactToDelete.count))", color: .white, font: .system(size: 18, weight: .semibold, design: .default), alignment: .center)
                        
                        Spacer()
                    }
                    .frame(height: 58)
                    .background(Color(hex: "F34235"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(16)
                .disabled(viewModel.arrContactToDelete.isEmpty)
                .opacity(!viewModel.arrContactToDelete.isEmpty ? 1 : 0.7)
            }
            .background(Color(hex: "232531"))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 10)
            .padding(.bottom, 15)
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
                        .frame(width: 35, height: 35)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
        }
        .background(Color(hex: "191D2B"))
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .onTapGesture {
            viewModel.btnEditFullContactAction(contact: contact)
        }
    }
}
