//
//  SpeetTestView.swift
//  CleanerApp
//
//  Created by iMac on 30/01/26.
//

import SwiftUI

struct SpeetTestView: View {
    
    let url = URL(string: "https://fast.com/")!
    
    var body: some View {
        ZStack {
            LinearGradient.orangeBg.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                speedTestSection
            }
        }
        .navigationTitle("Speed Test")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
    
    private var speedTestSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            CNWebView(url: url)
        }
    }
}
