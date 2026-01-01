//
//  DuplicateContactMenuViewModel.swift
//  CleanerApp
//
//  Created by iMac on 09/12/25.
//

import Foundation
import Combine

class DuplicateContactMenuViewModel: ObservableObject {
    
    var duplicateContact: DuplicateContactModel
    var arrDuplicateMenu: [DuplicateContact] = []
    
    init(duplicateContact: DuplicateContactModel) {
        self.duplicateContact = duplicateContact
        
        arrDuplicateMenu = [
            duplicateContact.arrDuplicateName,
            duplicateContact.arrDuplicateNumber,
            duplicateContact.arrDuplicateEmail,
        ]
    }
    
    func btnMenuRow(duplicateContact: DuplicateContact) {
        let viewModel = DuplicateContactGroupViewModel(duplicateContact: duplicateContact)
        NavigationManager.shared.push(to: .duplicateContactGroupView(destination: DuplicateContactGroupViewDestination(viewModel: viewModel)))
    }
}
