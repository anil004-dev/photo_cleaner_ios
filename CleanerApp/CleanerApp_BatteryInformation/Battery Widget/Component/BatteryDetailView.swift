//
//  BatteryDetailView.swift
//  CleanerApp
//
//  Created by iMac on 01/01/26.
//


import SwiftUI

struct BatteryDetailView: View {
    let batteryInfo: BatteryInfoEntry

    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 5) {
                Spacer()
                
                HStack(alignment: .center, spacing: 0) {
                    batteryInfoCellView(title: "Charging Status", isEnable: batteryInfo.batteryState == .charging)
                    
                    Spacer()
                    
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 1)
                        .frame(height: 50)
                    
                    Spacer()
                    
                    batteryInfoCellView(title: "Low Power Mode", isEnable: batteryInfo.isLowPowerModeOn)
                }
                
                Spacer()
                
                Rectangle()
                    .fill(Color.gray)
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
                
                Spacer()
                
                HStack(alignment: .center, spacing: 0) {
                    CNText(title: batteryInfo.formattedDate(), color: .white, font: .system(size: 12, weight: .medium, design: .default), alignment: .leading)
                    
                    Spacer(minLength: 0)
                    
                    CNText(title: batteryInfo.formattedTime(), color: .white, font: .system(size: 12, weight: .medium, design: .default), alignment: .trailing)
                }
                
                Spacer()
            }
        }
    }
    
    private func batteryInfoCellView(title: String, isEnable: Bool) -> some View {
        VStack(alignment: .center, spacing: 10) {
            CNText(title: "\(isEnable ? "YES" : "NO")", color: .cyan, font: .system(size: 18, weight: .bold, design: .default), alignment: .center)
            
            CNText(title: title, color: .white, font: .system(size: 11, weight: .medium, design: .default), alignment: .center)
        }
    }
}
