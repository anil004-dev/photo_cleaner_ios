//
//  UIImage + Custom.swift
//  CleanerApp
//
//  Created by iMac on 08/12/25.
//

import UIKit

extension UIImage {
    func resize(to target: CGSize) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: target, format: format)
        return renderer.image { _ in self.draw(in: CGRect(origin: .zero, size: target)) }
    }
}
