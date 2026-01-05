//
//  TabRouter.swift
//  CleanerApp
//
//  Created by IMac on 03/12/25.
//

import Combine

class TabRouter: ObservableObject {
    
    @Published var selectedTab: Int = 3
    static let shared = TabRouter()
}
