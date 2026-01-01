//
//  CNContactPreviewView.swift.swift
//  CleanerApp
//
//  Created by iMac on 10/12/25.
//


import SwiftUI
import ContactsUI

struct CNContactPreview: View {
    let contact: CNContact
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            CNContactPreviewController(contact: contact)
                .ignoresSafeArea(edges: .bottom)
                .toolbar(.visible, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

struct CNContactPreviewController: UIViewControllerRepresentable {
    let contact: CNContact
    
    func makeUIViewController(context: Context) -> CNContactViewController {
        let vc = CNContactViewController(for: contact.mutableCopy() as! CNMutableContact)
        vc.allowsEditing = false       // You don’t want editing in preview
        vc.allowsActions = false       // Hide message/call buttons etc.
        vc.navigationItem.largeTitleDisplayMode = .never
        return vc
    }
    
    func updateUIViewController(_ uiViewController: CNContactViewController, context: Context) {}
}
