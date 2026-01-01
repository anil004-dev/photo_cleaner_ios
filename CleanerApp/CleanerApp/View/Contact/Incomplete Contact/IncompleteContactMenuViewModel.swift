//
//  IncompleteContactMenuViewModel.swift
//  CleanerApp
//
//  Created by iMac on 10/12/25.
//

import Combine

class IncompleteContactMenuViewModel: ObservableObject {
    var incompleteContact: IncompleteContactModel
    @Published var arrIncompleteMenu: [IncompleteContact] = []
    
    init(incompleteContact: IncompleteContactModel) {
        self.incompleteContact = incompleteContact
        
        arrIncompleteMenu = [
            incompleteContact.arrNoName,
            incompleteContact.arrNoNumber,
            incompleteContact.arrNoEmail,
        ]
    }
    
    func btnMenuRow(incompleteContact: IncompleteContact) {
        guard !incompleteContact.arrContactGroup.isEmpty else { return }
        let viewModel = IncompleteContactListViewModel(incompleteContact: incompleteContact)
        viewModel.didUpdatedContact = { [weak self] contact in
            guard let self = self else { return }
            
            self.incompleteContact.updateEveryList(with: contact)
            self.arrIncompleteMenu = [
                self.incompleteContact.arrNoName,
                self.incompleteContact.arrNoNumber,
                self.incompleteContact.arrNoEmail,
            ]
        }
        
        viewModel.didRemovedContact = { [weak self] contact in
            guard let self = self else { return }
            
            self.incompleteContact.removeContact(contact: contact)
            self.arrIncompleteMenu = [
                self.incompleteContact.arrNoName,
                self.incompleteContact.arrNoNumber,
                self.incompleteContact.arrNoEmail,
            ]
        }
        
        NavigationManager.shared.push(to: .incompleteContactListView(destination: IncompleteContactListDestination(viewModel: viewModel)))
    }
}
