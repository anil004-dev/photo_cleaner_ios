//
//  CNAlertModel.swift
//  CleanerApp
//
//  Created by iMac on 03/12/25.
//

import Combine
import Foundation
import SwiftUI

struct CNAlertModel: Identifiable {
    let id = UUID()
    var title: String = ""
    var message: String = ""
    var leftButtonTitle: String = "OK"
    var leftButtonRole: ButtonRole? = nil
    var rightButtonTitle: String = ""
    var rightButtonRole: ButtonRole? = nil
    var leftButtonAction: (() -> Void)? = nil
    var rightButtonAction: (() -> Void)? = nil
}

class CNAlertManager: ObservableObject {
    static let shared = CNAlertManager()
    
    @Published var showAlert: Bool = false
    @Published var alertModel: CNAlertModel = CNAlertModel()
    
    private init() {}
    
    func showAlert(title: String = "",
                   message: String = "",
                   leftButtonTitle: String = "OK",
                   leftButtonRole: ButtonRole? = nil,
                   rightButtonTitle: String = "",
                   rightButtonRole: ButtonRole? = nil,
                   leftButtonAction: (() -> Void)? = nil,
                   rightButtonAction: (() -> Void)? = nil
    ) {
        var alertModel = CNAlertModel()
        alertModel.title = title
        alertModel.message = message
        alertModel.leftButtonTitle = leftButtonTitle
        alertModel.leftButtonRole = leftButtonRole
        alertModel.rightButtonTitle = rightButtonTitle
        alertModel.rightButtonRole = rightButtonRole
        alertModel.leftButtonAction = leftButtonAction
        alertModel.rightButtonAction = rightButtonAction
        
        self.alertModel = alertModel
        self.showAlert = true
    }
    
    func dismiss() {
        showAlert = false
    }
}
