//
//  CNNavButton.swift.swift
//  CleanerApp
//
//  Created by iMac on 03/12/25.
//


import SwiftUI

struct CNNavButton: View {
    let imageName: String
    let fontWeight: Font.Weight
    let iconColor: Color
    let iconSize: CGSize
    let backgroundColor: Color
    let isLeftButton: Bool
    
    var body: some View {
        if #available(iOS 26.0, *) {
            VStack {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .fontWeight(fontWeight)
                    .foregroundStyle(iconColor)
                    .frame(width: iconSize.width, height: iconSize.height)
            }
            .frame(width: 40, height: 40)
        } else {
            VStack {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .fontWeight(fontWeight)
                    .foregroundStyle(iconColor)
                    .frame(width: iconSize.width, height: iconSize.height)
            }
            .frame(width: 40, height: 40)
            .background {
                Circle()
                    .fill(backgroundColor)
            }
        }
    }
}
