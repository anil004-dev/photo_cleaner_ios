//
//  CNCircularProgressView.swift
//  CleanerApp
//
//  Created by iMac on 26/01/26.
//


import SwiftUI

struct CNCircularProgressView: View {
    
    var progress: Double
    
    var body: some View {
        ZStack {
            
            Circle()
                .stroke(
                    Color(hex: "414351"),
                    lineWidth: 15
                )
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.white,
                    style: StrokeStyle(
                        lineWidth: 15,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
        }
    }
}
