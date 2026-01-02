//
//  ThickProgressBar.swift
//  CleanerApp_WidgetExtension
//
//  Created by iMac on 01/01/26.
//

import SwiftUI

struct ThickProgressBar: View {

    let progress: CGFloat   // 0...1
    let height: CGFloat
    let label: String?

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {

                // Background
                Capsule()
                    .fill(Color.white.opacity(0.15))
                    .frame(height: height)

                // Progress
                Capsule()
                    .fill(Color.cyan)
                    .frame(
                        width: geo.size.width * progress,
                        height: height
                    )

                // Label at exact progress position
                if let label {
                    Text(label)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .offset(
                            x: max(
                                min(geo.size.width * progress - 14,
                                    geo.size.width - 28),
                                0
                            ),
                            y: 20
                        )
                        .frame(height: height)
                }
            }
        }
        .frame(height: height)
    }
}
