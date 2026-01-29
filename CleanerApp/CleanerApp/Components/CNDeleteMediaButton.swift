//
//  CNDeleteMediaButton.swift
//  CleanerApp
//
//  Created by iMac on 27/01/26.
//


import SwiftUI

struct CNDeleteMediaButton: View {
    let title: String
    let message: String
    let onTap: (() -> Void)
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            VStack(alignment: .center, spacing: 12) {
                Button {
                    onTap()
                } label: {
                    HStack(alignment: .center, spacing: 8) {
                        Image(systemName: "trash")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.white)
                            .frame(width: 19, height: 21)
                        
                        CNText(title: title, color: .white, font: .system(size: 18, weight: .semibold, design: .default), alignment: .center)
                    }
                    .frame(height: 58)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "F34235"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                CNText(title: message, color: .white, font: .system(size: 20, weight: .bold, design: .default), alignment: .center)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
        }
        .ifiOS26Unavailable { view in
            view
                .background(Color(hex: "232531"))
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .ifiOS26Available { view in
            if #available(iOS 26.0, *) {
                view
                    .background(Color(hex: "232531").opacity(0.5))
                    .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 20))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
