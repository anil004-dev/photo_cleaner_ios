//
//  TabRouter.swift
//  CleanerApp
//
//  Created by IMac on 03/12/25.
//

import Combine
import AVFoundation

class TabRouter: ObservableObject {
    
    @Published var selectedTab: Int = 0
    static let shared = TabRouter()
    
    @Published var showVideoPlayerView: (sheet: Bool, player: AVPlayer?) = (false, nil)
        
}
