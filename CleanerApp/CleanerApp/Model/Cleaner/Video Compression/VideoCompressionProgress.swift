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
    case high
    case medium
    case lossless

    /// Estimated average video bitrate (Mbps)
    /// Used ONLY for size estimation (not export)
    var estimatedBitrateMbps: Double {
        switch self {
        case .high:
            return 1.2

        case .medium:
            return 0.9

        case .lossless:
            return 8.0
        }
    }

    /// AVFoundation export preset
    var exportPreset: String {
        switch self {
        case .high:
            return AVAssetExportPresetLowQuality

        case .medium:
            return AVAssetExportPresetMediumQuality

        case .lossless:
            return AVAssetExportPresetHEVCHighestQuality
        }
    }

    /// Optional: for UI display
    var title: String {
        switch self {
        case .high:
            return "High Compression"
        case .medium:
            return "Medium Compression"
        case .lossless:
            return "Lossless"
        }
    }
}
