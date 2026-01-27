//
//  DuplicateMergePreview.swift
//  CleanerApp
//
//  Created by iMac on 09/12/25.
//

import SwiftUI

struct DuplicateMergePreview: View {
    
    @ObservedObject var viewModel: DuplicateMergePreviewModel
    
    var body: some View {
        ZStack {
            Color.bgDarkBlue.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                duplicateContactGroupSection
            }
        }
        .toolbar(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $viewModel.showContactPreview.sheet) {
            CNContactPreview(contact: viewModel.showContactPreview.contact)
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            CNText(title: "Merge Preview", color: .white, font: .system(size: 34, weight: .bold, design: .default), alignment: .trailing)
            
            CNText(title: "\(viewModel.arrContactGroup.count) Contacts", color: .init(hex: "7E828B"), font: .system(size: 12, weight: .semibold, design: .default), alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }
    
    private var duplicateContactGroupSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleSection
                .padding(.bottom, 8)
            
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(viewModel.arrContactGroup) { contactGroup in
                        contactGroupRow(group: contactGroup)
                    }
                }
                .padding(20)
            }
            
            VStack(alignment: .center, spacing: 0) {
                Button {
                    viewModel.btnMergeAction()
                } label: {
                    HStack(alignment: .center, spacing: 11) {
                        Spacer()
                        
                        Image(systemName: "arrow.trianglehead.merge")
                            .resizable()
                            .scaledToFit()
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(width: 15, height: 20)
                        
                        CNText(title: "Merge Contact (\(viewModel.arrContactGroup.count))", color: .white, font: .system(size: 18, weight: .semibold, design: .default), alignment: .center)
                        
                        Spacer()
                    }
                    .frame(height: 58)
                    .background(Color.btnBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(16)
            }
            .background(Color(hex: "232531"))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 10)
            .padding(.bottom, 15)
        }
    }
    
    @ViewBuilder private func contactGroupRow(group: ContactGroup) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 0) {
                CNText(title: "\(group.arrContacts.count) Contacts Merged", color: .white, font: .system(size: 20, weight: .medium, design: .default), alignment: .trailing)
                
                Spacer(minLength: 10)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .center, spacing: 10) {
                            VStack(alignment: .leading, spacing: 4) {
                                CNText(title: viewModel.getContactName(contactGroup: group), color: .white, font: .system(size: 17, weight: .medium, design: .default))
                                
                                CNText(title: viewModel.getContactNumber(contactGroup: group), color: Color(hex: "7F818D"), font: .system(size: 18, weight: .regular, design: .default))
                            }
                            
                            Spacer(minLength: 0)
                            
                            Image(systemName: "chevron.right")
                                .resizable()
                                .scaledToFit()
                                .fontWeight(.bold)
                                .foregroundStyle(Color(hex: "9395A2"))
                                .frame(width: 11, height: 16)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 26))
                    .background {
                        RoundedRectangle(cornerRadius: 26)
                            .fill(Color(hex: "0F1F4D"))
                            .stroke(Color(hex: "1756F6"), lineWidth: 2)
                    }
                }
                .padding(20)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.darkBlueCellBg)
            .clipShape(RoundedRectangle(cornerRadius: 36))
        }
    }
}
