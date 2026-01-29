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
            Color.bgDarkBlue.ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 0) {
                widgetSection
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private var widgetSection: some View {
        VStack(alignment: .center, spacing: 0) {
            CNText(title: "Widgets", color: .white, font: .system(size: 24, weight: .bold, design: .default), alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 6)
                .padding(.bottom, 15)
                .padding(.horizontal, 20)
            
            Picker("", selection: $viewModel.selectedWidgetKind) {
                Text("Storage")
                    .frame(height: 36)
                    .tag(WidgetKind.storage)
                
                Text("Battery")
                    .frame(height: 36)
                    .tag(WidgetKind.battery)
            }
            .tint(.btnBlue)
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            TabView(selection: $viewModel.selectedWidgetKind) {
                storageWidgetSection
                    .tag(WidgetKind.storage)
                
                batteryWidgetSection
                    .tag(WidgetKind.battery)
                
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .padding(.bottom, 20)
            
            CNButton(title: "Set Widget") {
                viewModel.setWidget(kind: viewModel.selectedWidgetKind)
            }
            .frame(width: 200)
            .padding(.bottom, 20)
        }
    }
    
    private var storageWidgetSection: some View {
        GeometryReader { geoProxy in
            
            TabView(selection: $viewModel.selectedWidgetSize) {
                storageWidgetRow(size: .small, width: geoProxy.size.width)
                    .tag(WidgetSize.small)
                
                storageWidgetRow(size: .medium, width: geoProxy.size.width)
                    .tag(WidgetSize.medium)
            }
            .tabViewStyle(
                PageTabViewStyle(indexDisplayMode: .automatic)
            )
        }
    }

    
    private var batteryWidgetSection: some View {
        GeometryReader { geoProxy in
            
            TabView(selection: $viewModel.selectedWidgetSize) {
                batteryWidgetRow(size: .small, width: geoProxy.size.width)
                    .tag(WidgetSize.small)
                
                batteryWidgetRow(size: .medium, width: geoProxy.size.width)
                    .tag(WidgetSize.medium)
            }
            .tabViewStyle(
                PageTabViewStyle(indexDisplayMode: .automatic)
            )
        }
    }
    
    @ViewBuilder private func storageWidgetRow(size: WidgetSize, width: CGFloat) -> some View {
        VStack(alignment: .center, spacing: 0) {
            let storageInfo = StorageInfoEntry()
            
            if size == .small {
                SmallStorageWidgetView(storageInfo: storageInfo)
                    .padding(20)
                    .background(.btnBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .shadow(color: .white.opacity(0.25), radius: 35, x: 0, y: 0)
                    .frame(width: 190, height: 190)
            } else {
                MediumStorageWidgetView(storageInfo: storageInfo)
                    .padding(20)
                    .background(.btnBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .shadow(color: .white.opacity(0.25), radius: 35, x: 0, y: 0)
                    .frame(height: 170)
                    .padding(.horizontal, 20)
            }
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .frame(width: width, alignment: .center)
        .id(size)
    }
    
    @ViewBuilder private func batteryWidgetRow(size: WidgetSize, width: CGFloat) -> some View {
        VStack(alignment: .center, spacing: 0) {
            let batteryInfo = BatteryInfoEntry()
            
            if size == .small {
                SmallBatteryWidgetView(batteryInfo: batteryInfo)
                    .padding(20)
                    .background(.btnBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .shadow(color: .white.opacity(0.25), radius: 35, x: 0, y: 0)
                    .frame(width: 190, height: 190)
            } else {
                MediumBatteryWidgetView(batteryInfo: batteryInfo)
                    .padding(20)
                    .background(.btnBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .shadow(color: .white.opacity(0.25), radius: 35, x: 0, y: 0)
                    .frame(height: 170)
                    .padding(.horizontal, 20)
            }
        }
        .frame(width: width, alignment: .center)
        .id(size)
    }
}
