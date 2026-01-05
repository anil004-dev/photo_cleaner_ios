//
//  ChargingAnimationPreviewViewModel.swift
//  CleanerApp
//
//  Created by iMac on 05/01/26.
//

import Combine

class ChargingAnimationPreviewViewModel: ObservableObject {
    @Published var chargingAnimation: ChargingAnimation
    var applyAnimation: (() -> Void)
    
    init(chargingAnimation: ChargingAnimation, applyAnimation: @escaping (() -> Void)) {
        self._chargingAnimation = Published(initialValue: chargingAnimation)
        self.applyAnimation = applyAnimation
    }
}
