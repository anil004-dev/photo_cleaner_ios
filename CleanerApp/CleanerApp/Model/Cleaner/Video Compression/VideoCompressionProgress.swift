//
//  VideoCompressionProgress.swift
//  CleanerApp
//
//  Created by iMac on 26/12/25.
//

import AVFoundation

struct VideoCompressionProgress: Identifiable {
    let id: String
    var progress: Double
    var isCompleted: Bool
}

enum VideoCompressionQuality {
    case low
    case medium
    case high

    
    var title: String {
        switch self {
        case .low:
            return "Low (80%)"
        case .medium:
            return "Medium (50%)"
        case .high:
            return "High (20%)"
        }
    }
}
