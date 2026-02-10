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
    let image: ImageResource
}

class SettingsViewModel: ObservableObject {
    
    let arrSection: [SettingSection] = [
        SettingSection(
            title: "Utilities",
            arrOption: [
                SettingOption(title: "Set Widget", image: .imgSetWidget),
                SettingOption(title: "Speed Test", image: .imgSpeedTest)
            ]
        ),
        
        SettingSection(
            title: "Get in Touch",
            arrOption: [
                SettingOption(title: "Rate our app", image: .imgRateOurApp),
                SettingOption(title: "Share our app", image: .imgShareOurApp)
            ]
        ),
        
        SettingSection(
            title: "Support",
            arrOption: [
                SettingOption(title: "Contact Us", image: .imgContactUs),
                SettingOption(title: "Terms", image: .imgTerms),
                SettingOption(title: "Privacy", image: .imgPrivacy)
            ]
        )
    ]
    
    @Published var showShareAppView: Bool = false
    
    func btnOptionAction(option: SettingOption) {
        let title = option.title
        
        switch title {
        case "Set Widget":
            openWidgetListView()
            
        case "Speed Test":
            openSpeedTestView()
            
        case "Share our app":
            shareApp()
            
        case "Rate our app":
            rateUs()
            
        case "Contact Us":
            contactUs()
            
        case "Terms":
            termsofServices()
            
        case "Privacy":
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
