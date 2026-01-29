//
//  View + Custom.swift
//  CleanerApp
//
//  Created by iMac on 05/12/25.
//

import SwiftUI

extension View {
    
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        @ViewBuilder transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func ifiOS26Available<Content: View>(
        @ViewBuilder _ transform: (Self) -> Content
    ) -> some View {
        if #available(iOS 26.0, *) {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func ifiOS26Unavailable<Content: View>(
        @ViewBuilder _ transform: (Self) -> Content
    ) -> some View {
        if #available(iOS 26.0, *) {
            self
        } else {
            transform(self)
        }
    }
}
