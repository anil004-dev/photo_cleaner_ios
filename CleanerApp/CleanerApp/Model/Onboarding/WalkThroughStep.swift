//
//  WalkThroughStep.swift
//  CleanerApp
//
//  Created by iMac on 23/01/26.
//


import SwiftUI

struct WalkThroughStep: Identifiable {
    let id = UUID()
    let image: ImageResource
    let title: String
    let description: String
}
