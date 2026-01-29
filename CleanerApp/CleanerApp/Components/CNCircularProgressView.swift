//
//  CNCircularProgressView.swift
//  CleanerApp
//
//  Created by iMac on 26/01/26.
//


import SwiftUI

struct CNCircularProgressView: View {
    
    var progress: Double
    var lineWidth: Double = 15
    
    var body: some View {
        ZStack {
            
            Circle()
                .stroke(
                    Color.white.opacity(0.2),
                    lineWidth: lineWidth
                )
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.white,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
        }
    }
}
