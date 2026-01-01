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
            Color.cnThemeBg.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                mergePreviewSection
            }
        }
        .navigationTitle("Merge Preview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $viewModel.showContactPreview.sheet) {
            CNContactPreview(contact: viewModel.showContactPreview.contact)
        }
    }
    
    private var mergePreviewSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.arrContactGroup) { contactGroup in
                        contactGroupRow(group: contactGroup)
                    }
                }
                .padding(.horizontal, 20)
            }
            
            VStack(alignment: .center, spacing: 20) {
                CNButton(title: "Merge \(viewModel.arrContactGroup.count)") {
                    viewModel.btnMergeAction()
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 15)
        }
    }
    
    @ViewBuilder private func contactGroupRow(group: ContactGroup) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                CNText(title: "\(group.arrContacts.count) Duplicate Contacts", color: .white, font: .system(size: 15, weight: .medium, design: .default), alignment: .trailing)
                    .padding(.vertical, 10)
                
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 10) {
                        CNText(title: viewModel.getContactName(contactGroup: group), color: .white, font: .system(size: 15, weight: .medium, design: .default))
                        
                        CNText(title: viewModel.getContactNumber(contactGroup: group), color: .gray, font: .system(size: 15, weight: .medium, design: .default))
                    }
                    .padding(10)
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
            .padding(15)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.darkBlueCellBg)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
            viewModel.showContactPreview(contactGroup: group)
        }
    }
}
