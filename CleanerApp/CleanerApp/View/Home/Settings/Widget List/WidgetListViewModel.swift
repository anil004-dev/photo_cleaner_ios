//
//  WidgetListViewModel.swift
//  CleanerApp
//
//  Created by iMac on 01/01/26.
//

import Combine
import Foundation

enum WidgetSize: Int, CaseIterable, Identifiable {
    case small
    case medium
    var id: Int { rawValue }
}

class WidgetListViewModel: ObservableObject {
    
    @Published var selectedWidgetKind: WidgetKind = .storage
    @Published var selectedWidgetSize: WidgetSize = .small
    
    
    func setWidget(kind: WidgetKind) {
        UserDefaultManager.selectedWidget = kind
        WidgetDataProvider.shared.updateAll()
    }
}
