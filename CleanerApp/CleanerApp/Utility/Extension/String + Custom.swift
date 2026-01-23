//
//  String + Custom.swift
//  CleanerApp
//
//  Created by iMac on 03/12/25.
//

import Foundation
import UIKit
import Photos

import Foundation

extension String {
    func normalizedPhone() -> String {
        return self.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }

    func normalizedEmail() -> String {
        return self.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func trimmed() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

