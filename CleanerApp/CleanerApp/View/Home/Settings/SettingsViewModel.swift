//
//  SettingsViewModel.swift
//  CleanerApp
//
//  Created by iMac on 30/01/26.
//

import Combine
import SwiftUI

struct SettingSection: Identifiable {
    let id = UUID()
    let title: String
    let arrOption: [SettingOption]
}

struct SettingOption: Identifiable {
    let id = UUID()
    let title: String
    let subTitle: String
    let imageName: String
}

class SettingsViewModel: ObservableObject {
    
    let arrSection: [SettingSection] = [
        SettingSection(
            title: "Utilities",
            arrOption: [
                SettingOption(title: "Widget", subTitle: "Key insights, always at a glance.", imageName: "widget.small"),
                SettingOption(title: "Speed Test", subTitle: "Get accurate internet speed results, fast.", imageName: "globe")
            ]
        ),
        
        SettingSection(
            title: "Get in Touch",
            arrOption: [
                SettingOption(title: "Share App", subTitle: "Share this app with friends and family.", imageName: "square.and.arrow.up"),
                SettingOption(title: "Rate Us", subTitle: "Share your feedback on the App Store.", imageName: "star.fill")
            ]
        )
    ]
    
    let supportSection: SettingSection = SettingSection(
        title: "Support",
        arrOption: [
            SettingOption(title: "Contact Us", subTitle: "Share this app with friends and family.", imageName: "envelope"),
            SettingOption(title: "Terms of Services", subTitle: "Share your feedback on the App Store.", imageName: "text.page"),
            SettingOption(title: "Privacy Policy", subTitle: "Share your feedback on the App Store.", imageName: "hand.raised")
        ]
    )
    
    @Published var showShareAppView: Bool = false
    
    func btnOptionAction(option: SettingOption) {
        let title = option.title
        
        switch title {
        case "Widget":
            openWidgetListView()
            
        case "Speed Test":
            openSpeedTestView()
            
        case "Share App":
            shareApp()
            
        case "Rate Us":
            rateUs()
            
        case "Contact Us":
            contactUs()
            
        case "Terms of Services":
            termsofServices()
            
        case "Privacy Policy":
            privacyPolicy()
            
        default: break
        }
    }
    
    func openWidgetListView() {
        NavigationManager.shared.push(to: .widgetListView)
    }
    
    func openSpeedTestView() {
        NavigationManager.shared.push(to: .speedTestView)
    }
    
    func shareApp() {
        showShareAppView = true
    }
    
    func rateUs() {
        if let appReviewURL = URL(string: CNConstant.appReviewURL), UIApplication.shared.canOpenURL(appReviewURL) {
            UIApplication.shared.open(appReviewURL)
        }
    }
    
    func contactUs() {
        let email = "bhautikamipara004@gmail.com"
        let subject = "\(Utility.getAppName()) Contact Us"
        let body = "Hello, I need help with..."
        
        let emailString = "mailto:\(email)?subject=\(subject)&body=\(body)"
        if let emailURL = emailString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: emailURL),UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func termsofServices() {
        if let url = URL(string: CNConstant.termsConditionURL) {
            UIApplication.shared.open(url)
        }
    }
    
    func privacyPolicy() {
        if let url = URL(string: CNConstant.privacyPolicyURL) {
            UIApplication.shared.open(url)
        }
    }
}
