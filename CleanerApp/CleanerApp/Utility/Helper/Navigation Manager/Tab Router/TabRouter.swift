//
//  TabRouter.swift
//  CleanerApp
//
//  Created by IMac on 03/12/25.
//

import Combine

class TabRouter: ObservableObject {
    
    @Published var selectedTab: Int = 1
    static let shared = TabRouter()
}
