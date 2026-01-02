//
//  WidgetListView.swift
//  CleanerApp
//
//  Created by iMac on 01/01/26.
//

import SwiftUI
import WidgetKit

struct WidgetListView: View {
    
    @StateObject var viewModel = WidgetListViewModel()
    
    var body: some View {
        ZStack {
            Color.cnThemeBg.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                widgetCategorySection
            }
        }
        .navigationTitle("Widgets")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
    }
    
    private var widgetCategorySection: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(viewModel.arrCategories) { category in
                    widgetRow(category: category)
                }
            }
        }
    }
    
    private func widgetRow(category: WidgetCategory) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                
                CNText(title: category.name, color: .white, font: .system(size: 12, weight: .medium, design: .default), alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                
                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 20) {
                        let batteryInfo = BatteryInfoEntry()
                        let storageInfo = StorageInfoEntry()
                        
                        VStack(alignment: .center, spacing: 0) {
                            if category.kind == .battery {
                                SmallBatteryWidgetView(batteryInfo: batteryInfo)
                                .padding()                        } else {
                                    SmallStorageWidgetView(storageInfo: storageInfo)
                                        .padding()
                                }
                        }
                        .frame(width: 160, height: 160)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .onTapGesture {
                            viewModel.setWidgetCategory(category: category)
                        }
                        
                        VStack(alignment: .center, spacing: 0) {
                            if category.kind == .battery {
                                MediumBatteryWidgetView(batteryInfo: batteryInfo)
                                    .padding()
                            } else {
                                MediumStorageWidgetView(storageInfo: storageInfo)
                                    .padding()
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width - 20, height: 160)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .onTapGesture {
                            viewModel.setWidgetCategory(category: category)
                        }
                        
                        VStack(alignment: .center, spacing: 0) {
                            if category.kind == .battery {
                                LargeBatteryWidgetView(batteryInfo: batteryInfo)
                                    .scaleEffect(0.9)
                            } else {
                                LargeStorageWidgetView(storageInfo: storageInfo)
                                    .scaleEffect(0.9)
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width - 20)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .onTapGesture {
                            viewModel.setWidgetCategory(category: category)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 15)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.darkBlueCellBg)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 20)
        }
    }
}
