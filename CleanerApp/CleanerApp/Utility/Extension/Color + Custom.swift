//
//  Color + Custom.swift
//  CleanerApp
//
//  Created by iMac on 10/12/25.
//

import Foundation
import SwiftUI

extension Color {
    
    /// Create a Color from RGB values (0-255) and optional alpha
    init(r: Double, g: Double, b: Double, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: r / 255.0,
            green: g / 255.0,
            blue: b / 255.0,
            opacity: opacity
        )
    }
    
    /// Create a Color from a Hex string (e.g. "#FF0000" or "FF0000").
    /// Returns `.white` if invalid.
    init(hex: String, opacity: Double = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            self = .white
            return
        }
        
        if hexSanitized.count == 6 {
            let r = Double((rgb & 0xFF0000) >> 16)
            let g = Double((rgb & 0x00FF00) >> 8)
            let b = Double(rgb & 0x0000FF)
            self.init(r: r, g: g, b: b, opacity: opacity)
        } else {
            self = .white
        }
    }
}

extension LinearGradient {
    
    
    static var blueBg: LinearGradient {
        LinearGradient(
            colors: [
                //Color(hex: "0A84FF"),
                //Color(hex: "4D9FFF")
                
//                Color(hex: "0A84FF"),
//                Color(hex: "4D9FFF"),
//                Color(hex: "E9F3FF"),
//                Color(hex: "F7FBFF")
           
//                Color(hex: "076FDB"),
//                Color(hex: "3E8EEB"),
//                Color(hex: "D7E7FD"),
//                Color(hex: "EAF2FA"),
//                Color(hex: "076FDB")
                
                Color(hex: "055EC4"),
                Color(hex: "367FD6"),
                Color(hex: "A9C9F1"),
                Color(hex: "A9C9F1")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
