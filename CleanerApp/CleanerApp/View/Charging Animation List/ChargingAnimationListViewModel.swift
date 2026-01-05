//
//  ChargingAnimationListViewModel.swift
//  CleanerApp
//
//  Created by iMac on 05/01/26.
//

import Combine

class ChargingAnimationListViewModel: ObservableObject {
    
    @Published var arrChargAnimations: [ChargingAnimation] = ChargingAnimationManager.shared.getAllAnimations()
    
    func openChargingAnimationPreviewScreen(animation: ChargingAnimation) {
        let viewModel = ChargingAnimationPreviewViewModel(
            chargingAnimation: animation,
            applyAnimation: { [weak self] in
                guard let self = self else { return }
                NavigationManager.shared.pop()
                self.setChargingAnimation(animation: animation)
            }
        )
        
        let destination = ChargingAnimationPreviewDestination(viewModel: viewModel)
        NavigationManager.shared.push(to: .chargingAnimationPreviewView(destination: destination))
    }
    
    func setChargingAnimation(animation: ChargingAnimation) {
        ChargingAnimationManager.shared.setChargingAnimation(animation: animation)
    }
}
