//
//  CNButton.swift
//  CleanerApp
//
//  Created by iMac on 03/12/25.
//


import SwiftUI

struct CNButton: View {
    let title: String
    var bgColor: Color = Color.btnBlue
    var height: CGFloat = 51
    let onTap: (() -> ())
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(alignment: .center, spacing: 0) {
                CNText(title: title, color: .white, font: .system(size: 18, weight: .semibold, design: .default), alignment: .center)
            }
            .frame(maxWidth: .infinity, minHeight: height, maxHeight: height, alignment: .center)
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: 17))
            .shadow(color: .black.opacity(0.16), radius: 1, x: 0, y: 0)
        }
    }
}
