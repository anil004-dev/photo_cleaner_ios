//
//  CompressVideoOptionView.swift
//  CleanerApp
//
//  Created by iMac on 30/01/26.
//

import SwiftUI

struct CompressVideoOptionView: View {
    
    @StateObject var viewModel: CompressVideoOptionViewModel
    
    init(mediaItem: MediaItem, compressInfo: VideoCompressionInfo) {
        self._viewModel = StateObject(wrappedValue: CompressVideoOptionViewModel(mediaItem: mediaItem, compressInfo: compressInfo))
    }
    
    var body: some View {
        ZStack {
            LinearGradient.orangeBg.ignoresSafeArea()
            
            videoPreviewSection
                .ignoresSafeArea(edges: .bottom)
        }
        .toolbar(.hidden, for: .tabBar)
    }
    
    private var videoPreviewSection: some View {
        VStack(alignment: .center, spacing: 0) {
            CNMediaPreview(mediaItem: viewModel.mediaItem)
                .padding(.vertical, 27)
        }
        .safeAreaInset(edge: .bottom) {
            compressOptionSection
        }
    }
    
    private var compressOptionSection: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                CNText(title: "You can save around  ", color: .txtBlack, font: .system(size: 15, weight: .medium, design: .default), alignment: .center)
                
                CNText(title: viewModel.compressInfo.formattedSavedSize, color: .primOrange, font: .system(size: 15, weight: .bold, design: .default), alignment: .center)
            }
            .padding(.top, 16)
            .padding(.bottom, 10)
            
            HStack(alignment: .center, spacing: 10) {
                CNText(title: viewModel.compressInfo.formattedOriginalSize, color: .txtBlack, font: .system(size: 25, weight: .semibold, design: .default), alignment: .center)
                
                Image(.icChevronDouble)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.txtBlack)
                    .frame(width: 14, height: 13)
                
                CNText(title: viewModel.compressInfo.formattedEstimatedSize, color: .txtBlack, font: .system(size: 25, weight: .semibold, design: .default), alignment: .center)
            }
            .padding(.bottom, 12)
            
            HStack(alignment: .center, spacing: 12) {
                CNText(title: "Compress Up to", color: .txtBlack, font: .system(size: 15, weight: .medium, design: .default), alignment: .center)
                
                Menu {
                    ForEach(VideoCompressionQuality.allCases, id: \.self) { quality in
                        Button {
                            viewModel.selectQuality(quality: quality)
                        } label: {
                            if viewModel.compressInfo.quality == quality {
                                Label(quality.title, systemImage: "checkmark")
                            } else {
                                Text(quality.title)
                            }
                        }
                    }
                } label: {
                    HStack(alignment: .center, spacing: 8) {
                        CNText(title: viewModel.compressInfo.quality.title, color: .txtBlack, font: .system(size: 15, weight: .medium, design: .default))
                            .padding(.leading, 16)
                        
                        Image(systemName: "chevron.up.chevron.down")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color.txtBlack)
                            .frame(width: 12, height: 15)
                            .padding(.trailing, 16)
                    }
                    .frame(height: 44)
                    .ifiOS26Available { view in
                        if #available(iOS 26.0, *) {
                            view
                                .background(Color(hex: "1A1A1A").opacity(0.1))
                                .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 20))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                    .ifiOS26Unavailable { view in
                        view
                            .background(Color(hex: "1A1A1A").opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
            }
            .padding(.bottom, 16)
            
            Button {
                viewModel.btnCompressVideoAction()
            } label: {
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: "rectangle.compress.vertical")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.white)
                        .frame(width: 27, height: 24)
                    
                    CNText(title: "Start Compressing", color: .white, font: .system(size: 18, weight: .semibold, design: .default), alignment: .center)
                }
                .frame(maxWidth: .infinity, minHeight: 55, maxHeight: 55, alignment: .center)
                .background(Color.primOrange)
                .clipShape(RoundedRectangle(cornerRadius: 17))
            }
            .padding(.bottom, 25)
            .padding(.horizontal, 26)
        }
        .background(Color.white)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24))
    }
}
