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
            VStack(alignment: .center, spacing: 5) {
                Button {
                    onTap()
                } label: {
                    HStack(alignment: .center, spacing: 8) {
                        Image(.icBin)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 19, height: 22)
                        
                        CNText(title: title, color: .white, font: .system(size: 18, weight: .semibold, design: .default), alignment: .center)
                    }
                    .frame(height: 58)
                    .frame(maxWidth: .infinity)
                    .background(Color.btnRed)
                    .clipShape(RoundedRectangle(cornerRadius: 29))
                }
                
                CNText(title: message, color: .txtBlack, font: .system(size: 16, weight: .medium, design: .default), alignment: .center)
            }
            .padding(26)
            .padding(.bottom, 10)
        }
        .background(Color.white)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 30, topTrailingRadius: 30))
        .transition(.move(edge: .bottom))
        .shadow(color: .black.opacity(0.11), radius: 8, x: 0, y: 0)
    }
}
