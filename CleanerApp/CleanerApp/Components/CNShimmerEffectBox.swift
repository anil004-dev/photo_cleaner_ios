//
//  CNShimmerEffectBox.swift
//  CleanerApp
//
//  Created by iMac on 29/01/26.
//


import SwiftUI

struct CNShimmerEffectBox: View {
    
    private var gradientColors = [
        Color (uiColor: UIColor.systemGray5),
        Color(uiColor: UIColor.systemGray6),
        Color(uiColor: UIColor.systemGray5)
    ]
    
    @State var startPoint: UnitPoint = .init(x: -1, y: 0.5)
    @State var endPoint: UnitPoint = .init(x: 0, y: 0.5)
    
    var body: some View {
        LinearGradient(colors: gradientColors,
                       startPoint: startPoint, endPoint: endPoint)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.3)
                .repeatForever (autoreverses: false)) {
                    startPoint = .init(x: 1.5, y: 0.5)
                    endPoint = .init(x: 2.5, y: 0.5)
                }
        }
    }
}
