//
//  VideoCompressionProgress.swift
//  CleanerApp
//
//  Created by iMac on 26/12/25.
//

import AVFoundation
import Photos

struct VideoCompressionInfo {
    let originalSize: Int64
    let estimatedSize: Int64
    let savedSize: Int64
    let quality: VideoCompressionQuality
    
    var formattedOriginalSize: String {
        return Utility.formattedSize(byte: originalSize)
    }
    
    var formattedEstimatedSize: String {
        return Utility.formattedSize(byte: estimatedSize)
    }
    
    var formattedSavedSize: String {
        return Utility.formattedSize(byte: savedSize)
    }
}

enum VideoCompressionQuality: Int, CaseIterable {
    case low
    case medium
    case high
    
    /// Target bitrate in Mbps
    var targetBitrate: Double {
        switch self {
        case .low: return 1.0   // 1 Mbps
        case .medium: return 2.5 // 2.5 Mbps
        case .high: return 5.0   // 5 Mbps
        }
    }
    
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
