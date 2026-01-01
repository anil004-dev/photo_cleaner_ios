//
//  CNLoaderView.swift
//  CleanerApp
//
//  Created by iMac on 05/12/25.
//


import SwiftUI

struct CNLoaderView: View {
    @State private var isVisible = false
    
    var body: some View {
        ZStack {
            if isVisible {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                VStack(spacing: 30) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
                .padding(40)
                //.background(Color.white)
                .cornerRadius(14)
                .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isVisible)
        .onAppear {
            isVisible = true
        }
        .onDisappear {
            isVisible = false
        }
    }
}

// MARK: - Global Interface

enum CNLoader {
    static func show() {
        LoaderWindowManager.shared.show()
    }
    
    static func dismiss() {
        LoaderWindowManager.shared.dismiss()
    }
}

// MARK: - Private Manager

private final class LoaderWindowManager {
    static let shared = LoaderWindowManager()
    private var loaderWindow: UIWindow?
    private var isAnimating = false
    
    func show() {
        guard loaderWindow == nil else {
            return
        }
        
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first else {
            return
        }
        
        let window = UIWindow(windowScene: windowScene)
        let hostingController = UIHostingController(rootView: CNLoaderView())
        hostingController.view.backgroundColor = .clear
        window.rootViewController = hostingController
        window.windowLevel = .alert + 1
        window.makeKeyAndVisible()
        loaderWindow = window
    }
    
    func dismiss() {
        guard !isAnimating else { return }
        isAnimating = true
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let loaderWindow = self.loaderWindow else {
                self?.isAnimating = false
                return
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                loaderWindow.alpha = 0
            }, completion: { _ in
                loaderWindow.isHidden = true
                self.loaderWindow = nil
                self.isAnimating = false
            })
        }
    }
}
