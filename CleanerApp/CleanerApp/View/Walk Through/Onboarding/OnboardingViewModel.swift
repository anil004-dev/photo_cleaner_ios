//
//  OnboardingViewModel.swift
//  CleanerApp
//
//  Created by iMac on 23/01/26.
//

import Combine
import SwiftUI

class OnboardingViewModel: ObservableObject {
    let arrSteps: [WalkThroughStep] = [
        WalkThroughStep(imageName: "img_delete_photo", title: "Delete Duplicate\nPhotos", description: "Identify duplicate photos and safely delete the ones you don’t need."),
        WalkThroughStep(imageName: "img_merge_contacts", title: "Merge or Delete\nDuplicate Contacts", description: "Identify duplicate contacts and choose whether to merge details or remove extras"),
        WalkThroughStep(imageName: "imge_free_up_storage", title: "Free Up\niPhone Storage", description: "Recover up to 80% of your storage in just a few taps"),
        WalkThroughStep(imageName: "img_charging_animation", title: "Battery Charging\nAnimation", description: "See your battery charge in real time with a stunning visual effect.")
    ]

    @Published var currentIndex: Int = 0
    @Published var progressValues: [Double] = Array(repeating: 0, count: 4)

    private var timer: AnyCancellable?
    private let slideDuration: Double = 3
    private let tick: Double = 0.03
    
    func onAppear() {
        reset()
        startProgress(for: 0)
    }

    private func reset() {
        currentIndex = 0
        progressValues = Array(repeating: 0, count: arrSteps.count)
    }

    private func startProgress(for index: Int) {
        timer?.cancel()

        let increment = tick / slideDuration

        timer = Timer.publish(every: tick, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }

                progressValues[index] += increment

                if progressValues[index] >= 1 {
                    progressValues[index] = 1
                    moveToNext()
                }
            }
    }

    private func moveToNext() {
        timer?.cancel()

        if currentIndex < arrSteps.count - 1 {
            withAnimation {
                currentIndex += 1
            }
            startProgress(for: currentIndex)
        }
    }

    func btnContinueAction() {
        timer?.cancel()

        progressValues[currentIndex] = 1

        if currentIndex < arrSteps.count - 1 {
            withAnimation {
                currentIndex += 1
            }
            
            startProgress(for: currentIndex)
        } else {
            UserDefaultManager.isWalkThroughCompleted = true
            AppState.shared.navigateToHomeFlow()
        }
    }
}
