//
//  CNContactEditView.swift
//  CleanerApp
//
//  Created by iMac on 10/12/25.
//


import SwiftUI
import ContactsUI

struct CNContactEditView: View {
    let contact: CNContact
    var onComplete: (CNContact?) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            CNContactVC(contact: contact, onComplete: onComplete)
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

struct CNContactVC: UIViewControllerRepresentable {
    let contact: CNContact
    var onComplete: (CNContact?) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> CNContactViewController {
        let vc = CNContactViewController(for: contact.mutableCopy() as! CNMutableContact)
        vc.delegate = context.coordinator
        vc.allowsEditing = true
        vc.allowsActions = true
        vc.navigationItem.largeTitleDisplayMode = .never
        return vc
    }
    
    func updateUIViewController(_ uiViewController: CNContactViewController,
                                context: Context) {}
    
    class Coordinator: NSObject, CNContactViewControllerDelegate {
        var parent: CNContactVC
        
        init(_ parent: CNContactVC) {
            self.parent = parent
        }
        
        func contactViewController(_ viewController: CNContactViewController,
                                   didCompleteWith contact: CNContact?) {
            parent.onComplete(contact)
        }
    }
}
