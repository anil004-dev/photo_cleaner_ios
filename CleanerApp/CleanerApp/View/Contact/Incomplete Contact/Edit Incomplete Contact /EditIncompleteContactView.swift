//
//  EditIncompleteContactView.swift
//  CleanerApp
//
//  Created by iMac on 10/12/25.
//

import SwiftUI

struct EditIncompleteContactView: View {
    
    @ObservedObject var viewModel: EditIncompleteContactViewModel
    
    var body: some View {
        ZStack {
            Color.cnThemeBg.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                contactDetailSection
            }
        }
        .navigationTitle("Fix Contact")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
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
        .alert(viewModel.showTFAlert.option.alertTitle, isPresented: $viewModel.showTFAlert.presented) {
            
            switch viewModel.showTFAlert.option {
            case .addName:
                TextField("", text: $viewModel.contactName)
            case .addNumber:
                TextField("", text: $viewModel.contactPhone)
                    .keyboardType(.phonePad)
            case .addEmail:
                TextField("", text: $viewModel.contactEmail)
                    .keyboardType(.emailAddress)
            }
            
            Button("Done") {
                viewModel.btnAlertDoneAction()
            }
            
            Button("Cancel", role: .cancel) {
               
            }
        } message: {
            Text("Please enter \(viewModel.showTFAlert.option.alertTitle.lowercased()) in the field below.")
        }
    }
    
    private var contactDetailSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 25) {
                    contactInfoSection
                    
                    if !viewModel.arrOptions.isEmpty {
                        fixOptionSection
                    }
                    
                    otherOptionSection
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var contactInfoSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            contactDetailRow(title: "Name", value: viewModel.contact.displayName ?? "-", showSeparator: true)
            contactDetailRow(title: "Phone", value: viewModel.contact.phoneNumbers.first ?? "-", showSeparator: true)
            contactDetailRow(title: "Email", value: viewModel.contact.emailAddresses.first ?? "-", showSeparator: false)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.darkBlueCellBg)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.clear)
                .stroke(Color.gray, lineWidth: 1)
        }
    }
    
    private var fixOptionSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            CNText(title: "Fix Options", color: .white, font: .system(size: 15, weight: .semibold, design: .default), alignment: .leading)
                .padding(.bottom, 15)
            
            VStack(alignment: .leading, spacing: 0) {
                
               
                ForEach(0..<viewModel.arrOptions.count, id: \.self) { index in
                    let option = viewModel.arrOptions[index]
                    fixOptionRow(option: option, showSeparator: index+1 != viewModel.arrOptions.count)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.darkBlueCellBg)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.clear)
                    .stroke(Color.gray, lineWidth: 1)
            }
        }
    }
    
    private var otherOptionSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            otherOptionRow(title: "Edit full contact", color: .white, showSeparator: true)
                .onTapGesture {
                    viewModel.btnEditFullContactAction()
                }
            
            otherOptionRow(title: "Delete contact", color: .red, showSeparator: false)
                .onTapGesture {
                    viewModel.btnDeleteContactAction()
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.darkBlueCellBg)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.clear)
                .stroke(Color.gray, lineWidth: 1)
        }
    }
    
    @ViewBuilder
    private func contactDetailRow(title: String, value: String, showSeparator: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                CNText(title: title, color: .white, font: .system(size: 15, weight: .semibold, design: .default), alignment: .leading)
                
                Spacer(minLength: 0)
                
                CNText(title: value, color: .white, font: .system(size: 15, weight: .medium, design: .default), alignment: .trailing)
            }
            .padding(.vertical, 15)
            
            Divider()
        }
        .padding(.horizontal, 15)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func fixOptionRow(option: FixOption, showSeparator: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(alignment: .center, spacing: 0) {
                CNText(title: option.title, color: .white, font: .system(size: 15, weight: .semibold, design: .default), alignment: .leading)
            }
            .padding(.vertical, 15)
            
            Divider()
        }
        .padding(.horizontal, 15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.darkBlueCellBg)
        .onTapGesture {
            viewModel.btnFixOptionAction(option: option)
        }
    }
    
    @ViewBuilder
    private func otherOptionRow(title: String, color: Color, showSeparator: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                CNText(title: title, color: color, font: .system(size: 15, weight: .semibold, design: .default), alignment: .leading)
            }
            .padding(.vertical, 15)
            
            Divider()
        }
        .padding(.horizontal, 15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.darkBlueCellBg)
    }
}
