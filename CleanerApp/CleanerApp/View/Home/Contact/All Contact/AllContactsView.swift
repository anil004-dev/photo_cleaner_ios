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
            LinearGradient.orangeBg.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                allContactSection
            }
        }
        .navigationTitle("All Contacts")
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
                allContactListSection
            }
        }
    }
    
    private var titleSection: some View {
        HStack(alignment: .center, spacing: 5) {
            CNText(title: "\(viewModel.arrContacts.count) Contacts", color: .txtBlack, font: .system(size: 18, weight: .semibold, design: .default), alignment: .trailing)
            
            Spacer(minLength: 0)
            
            if !viewModel.arrContacts.isEmpty {
                let isAllSelected = viewModel.arrContacts.allSatisfy({ $0.isSelected })
                
                Button {
                    if !isAllSelected  {
                        viewModel.btnSelectAllAction()
                    } else {
                        viewModel.btnDeselectAllAction()
                    }
                } label: {
                    CNText(title: isAllSelected ? "Deselect All" : "Select All", color: .primOrange, font: .system(size: 17, weight: .bold, design: .default), alignment: .center)
                }
            }
        }
        .padding(.leading, 16)
        .padding(.trailing, 20)
        .padding(.top, 27)
    }
    
    private var allContactListSection: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                titleSection
                    .padding(.bottom, 13)
                
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(0..<viewModel.arrContacts.count, id: \.self) { index in
                            let contact = viewModel.arrContacts[index]
                            contactRow(
                                contact: contact,
                                showSeparator: index+1 != viewModel.arrContacts.count
                            )
                        }
                    }
                    .padding(.vertical, 5)
                }
                .background(Color(hex: "FDFDFD"))
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .padding(.horizontal, 16)
                .padding(.bottom, viewModel.arrContactToDelete.isEmpty ? 25 : 13)
                .scrollIndicators(.hidden)
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
                .background(Color.btnRed)
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
    
    @ViewBuilder private func contactRow(contact: ContactModel, showSeparator: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 10) {
                HStack(alignment: .center, spacing: 0) {
                    CNText(title: contact.intialName, color: .primOrange, font: .system(size: 20, weight: .heavy, design: .default), alignment: .center)
                }
                .frame(width: 46, height: 46)
                .background(Color(hex: "F4F4F4"))
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    CNText(title: contact.displayName ?? "No Name", color: .txtBlack, font: .system(size: 17, weight: .semibold, design: .default))
                    
                    CNText(title: contact.phoneNumbers.first ?? "-", color: Color(hex: "7F818D"), font: .system(size: 14, weight: .regular, design: .default))
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
                .padding(.trailing, 6)
            }
            .padding(.vertical, 12)
            
            if showSeparator {
                Rectangle()
                    .fill(Color(hex: "F0F0F0"))
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 14)
    }
}
