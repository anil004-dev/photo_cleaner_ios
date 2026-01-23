//
//  UIApplication + Custom.swift
//  CleanerApp
//
//  Created by iMac on 23/01/26.
//


import UIKit

extension UIApplication {

    func topViewController(
        base: UIViewController? = nil
    ) -> UIViewController? {

        let baseVC = base ??
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first { $0.isKeyWindow }?
            .rootViewController

        if let nav = baseVC as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }

        if let tab = baseVC as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }

        if let presented = baseVC?.presentedViewController {
            return topViewController(base: presented)
        }

        return baseVC
    }
}
