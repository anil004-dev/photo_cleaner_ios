//
//  WidgetViewModel.swift
//  CleanerApp
//
//  Created by iMac on 01/01/26.
//

import Combine
import Foundation

struct WidgetCategory: Identifiable {
    var id = UUID()
    let name: String
    let kind: WidgetKind
    let arrWidgets: [String]
}

class WidgetViewModel: ObservableObject {
    
    @Published var arrCategories: [WidgetCategory] = [
        WidgetCategory(name: "Battery", kind: .battery, arrWidgets: ["Small", "Medium", "Large"]),
        WidgetCategory(name: "Storage", kind: .storage, arrWidgets: ["Small", "Medium", "Large"])
    ]
    
    func setWidgetCategory(category: WidgetCategory) {
        UserDefaultManager.selectedWidget = category.kind
        WidgetDataProvider.shared.updateAll()
    }
}
