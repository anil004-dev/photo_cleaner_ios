//
//  ChargingAnimationManager.swift
//  CleanerApp
//
//  Created by iMac on 05/01/26.
//

import SwiftUI

class ChargingAnimationManager {
    
    static let shared = ChargingAnimationManager()
    
    func getAllAnimations() -> [ChargingAnimation] {
        return [
            ChargingAnimation(type: .waterDrop),
            ChargingAnimation(type: .bubbleRing)
        ]
    }
    
    func setChargingAnimation(animation: ChargingAnimation) {
        UserDefaultManager.selectedChargingAnimation = animation.type
    }
    
    func getChargingAnimationType(animation: ChargingAnimation) -> ChargingAnimationType {
        return UserDefaultManager.selectedChargingAnimation ?? .none
    }
}
