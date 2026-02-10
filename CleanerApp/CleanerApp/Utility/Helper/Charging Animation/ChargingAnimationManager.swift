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
            ChargingAnimation(type: .waterDrop, name: "Quantum\nParticles"),
            ChargingAnimation(type: .bubbleRing, name: "Blue Core"),
            ChargingAnimation(type: .circularGlowingRing, name: "Prism Aura"),
            ChargingAnimation(type: .circularNoiseRing, name: "Spectrum Boost"),
            ChargingAnimation(type: .angularGlowingRing, name: "Cosmic Orbit"),
            ChargingAnimation(type: .rainDropBucket, name: "Cloud Energy")
        ]
    }
    
    func setChargingAnimation(animation: ChargingAnimation) {
        UserDefaultManager.selectedChargingAnimation = animation.type
    }
    
    func getChargingAnimationType(animation: ChargingAnimation) -> ChargingAnimationType {
        return UserDefaultManager.selectedChargingAnimation ?? .none
    }
}
