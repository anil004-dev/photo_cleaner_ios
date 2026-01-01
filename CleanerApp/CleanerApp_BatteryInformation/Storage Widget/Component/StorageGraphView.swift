//
//  StorageGraphView.swift
//  CleanerApp
//
//  Created by iMac on 01/01/26.
//


import SwiftUI

struct StorageGraphView: View {
    let storageInfo: StorageInfoEntry

    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 5) {
                Spacer()
                
                HStack(alignment: .center, spacing: 0) {
                    storageInfoCellView(title: "Used Storage", value: storageInfo.formatStorage(bytes: storageInfo.usedStorage))
                    
                    Spacer()
                    
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 1)
                        .frame(height: 50)
                    
                    Spacer()
                    
                    storageInfoCellView(title: "Free Storage", value: storageInfo.formatStorage(bytes: storageInfo.freeStorage))
                }
                
                Spacer()
                
                Rectangle()
                    .fill(Color.gray)
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
                
                Spacer()
                
                HStack(alignment: .center, spacing: 0) {
                    CNText(title: storageInfo.formattedDate(), color: .white, font: .system(size: 12, weight: .medium, design: .default), alignment: .leading)
                    
                    Spacer(minLength: 0)
                    
                    CNText(title: storageInfo.formattedTime(), color: .white, font: .system(size: 12, weight: .medium, design: .default), alignment: .trailing)
                }
                
                Spacer()
            }
        }
    }
    
    private func storageInfoCellView(title: String, value: String) -> some View {
        VStack(alignment: .center, spacing: 10) {
            CNText(title: value, color: .cyan, font: .system(size: 18, weight: .bold, design: .default), alignment: .center)
            
            CNText(title: title, color: .white, font: .system(size: 11, weight: .medium, design: .default), alignment: .center)
        }
    }
}
