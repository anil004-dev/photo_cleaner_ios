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
            LinearGradient.orangeBg.ignoresSafeArea()
            
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
                    HStack(alignment: .center, spacing: 10) {
                        Image(.icSqaureCheckmark)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color.txtBlack)
                            .frame(width: 18, height: 18)
                        
                        CNText(title: isAllSelected ? "Deselect All" : "Select All", color: .txtBlack, font: .system(size: 17, weight: .medium, design: .default), alignment: .center)
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
        HStack(alignment: .center, spacing: 5) {
            CNText(title: "Incomplete", color: .txtBlack, font: .system(size: 34, weight: .bold, design: .default), alignment: .trailing)
            
            Spacer(minLength: 0)
            
            CNText(title: "\(viewModel.incompleteContact.contactCount) Contacts", color: .init(hex: "7E828B"), font: .system(size: 12, weight: .semibold, design: .default), alignment: .trailing)
        }
        .padding(.leading, 16)
        .padding(.trailing, 20)
        .padding(.top, 10)
    }
    
    private var incompleteContactListSection: some View {
        ZStack(alignment: .bottom) {
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
                    .padding(.top, 14)
                    .padding(.bottom, 120)
                }
                .transition(.move(edge: .bottom))
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !viewModel.arrContactToDelete.isEmpty {
                deleteButton
            }
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .animation(.easeInOut, value: viewModel.arrContactToDelete.isEmpty)
    }
    
    private var deleteButton: some View {
        VStack(alignment: .center, spacing: 0) {
            Button {
                viewModel.btnDeleteAction()
            } label: {
                HStack(alignment: .center, spacing: 11) {
                    Spacer()
                    
                    Image(.icBin)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 19, height: 22)
                    
                    CNText(title: "Delete Selected (\(viewModel.arrContactToDelete.count))", color: .white, font: .system(size: 18, weight: .semibold, design: .default), alignment: .center)
                    
                    Spacer()
                }
                .frame(height: 58)
                .background(Color(hex: "F34235"))
                .clipShape(RoundedRectangle(cornerRadius: 29))
            }
            .padding(26)
            .padding(.bottom, 10)
            .disabled(viewModel.arrContactToDelete.isEmpty)
            .opacity(!viewModel.arrContactToDelete.isEmpty ? 1 : 0.7)
        }
        .background(Color.white)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 30, topTrailingRadius: 30))
        .transition(.move(edge: .bottom))
        .shadow(color: .black.opacity(0.11), radius: 8, x: 0, y: 0)
    }
    
    @ViewBuilder private func contactRow(contact: ContactModel) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    CNText(title: contact.displayName ?? "No Name", color: .txtBlack, font: .system(size: 17, weight: .medium, design: .default))
                    
                    CNText(title: contact.phoneNumbers.first ?? "-", color: Color(hex: "7F818D"), font: .system(size: 18, weight: .regular, design: .default))
                }
                
                Spacer(minLength: 0)
                
                let isSelected = contact.isSelected
                
                Button {
                    viewModel.selectContact(contact: contact)
                } label: {
                    Image(isSelected ? .icSquareCheckedNew : .icSquareUncheckedNew)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .animation(.easeInOut(duration: 0.1), value: isSelected)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .onTapGesture {
            viewModel.btnEditFullContactAction(contact: contact)
        }
    }
}
