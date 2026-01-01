//
//  StorageRingView.swift
//  CleanerApp
//
//  Created by iMac on 01/01/26.
//


import SwiftUI

struct StorageRingView: View {
    
    let storageInfo: StorageInfoEntry
    private var progress: CGFloat {
        CGFloat(storageInfo.usedStoragePercentage) / 100
    }
    
    var body: some View {
        VStack(spacing: 15) {
            
            CNText(title: "Storage", color: .white, font: .system(size: 14, weight: .bold, design: .default), alignment: .center)
                .font(.system(size: 14, weight: .bold, design: .default))

            ZStack {
                Circle()
                    .stroke(
                        Color.white.opacity(0.12),
                        lineWidth: 10
                    )

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                Color.blue,
                                Color.cyan,
                                Color.green,
                                Color.blue
                            ]),
                            center: .center
                        ),
                        style: StrokeStyle(
                            lineWidth: 10,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))

                
                CNText(title: "\(Int(storageInfo.usedStoragePercentage))%", color: .white, font: .system(size: 17, weight: .bold), alignment: .center)
            }
        }
    }
}
