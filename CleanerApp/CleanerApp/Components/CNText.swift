//
//  CNText.swift
//  CleanerApp
//
//  Created by iMac on 03/12/25.
//


import SwiftUI

struct CNText: View {
    let title: String
    let color: Color
    let font: Font
    var alignment: TextAlignment = .leading
    var minimumScale: CGFloat = 1.0
    var lineLimit: Int? = nil
    
    var body: some View {
        Text(title)
            .font(font)
            .foregroundStyle(color)
            .multilineTextAlignment(alignment)
            .minimumScaleFactor(minimumScale)
            .lineLimit(lineLimit)
            
    }
}
