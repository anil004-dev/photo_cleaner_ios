//
//  StillPhotoPreviewView.swift
//  CleanerApp
//
//  Created by iMac on 28/01/26.
//

import SwiftUI

struct StillPhotoPreviewView: View {
    
    @ObservedObject var viewModel: StillPhotoPreviewModel
    
    var body: some View {
        ZStack {
            LinearGradient.orangeBg.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                previewSection
            }
        }
        .toolbar(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            CNText(title: "Preview", color: .txtBlack, font: .system(size: 34, weight: .bold, design: .default))
                .padding(.horizontal, 17)
                .padding(.top, 16)
            
            VStack(alignment: .leading, spacing: 0) {
                let totalHorizontalPadding: CGFloat = (17 + 12) * 2
                let itemSpacing: CGFloat = 10
                let numberOfColumns: CGFloat =  2
                let availableWidth = UIScreen.main.bounds.width - totalHorizontalPadding - (itemSpacing * (numberOfColumns - 1))
                let itemWidth = availableWidth / numberOfColumns
                let itemHeight = itemWidth
                
                let columns = Array(
                    repeating: GridItem(.fixed(itemWidth), spacing: itemSpacing),
                    count: Int(numberOfColumns)
                )
                
                ScrollView(.vertical) {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        LazyVGrid(columns: columns, spacing: itemSpacing) {
                            ForEach(0..<viewModel.arrImageURLs.count, id: \.self) { index in
                                let url = viewModel.arrImageURLs[index]
                                
                                mediaItemCard(
                                    url: url,
                                    isSelected: url == viewModel.selectedImageURL,
                                    width: itemWidth,
                                    height: itemHeight,
                                    onTap: {
                                        
                                    }
                                )
                            }
                        }
                        .padding(12)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.primOrange, lineWidth: 2)
                    )
                    .background {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.primOrange)
                            .offset(x: 3.5, y: 3.5)
                    }
                    .padding(1)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 17)
                }
            }
            .padding(.top, 10)
            
            CNButton(title: "Save", bgColor: .primOrange) {
                viewModel.onSaveAction?(viewModel.selectedImageURL)
            }
            .padding(20)
        }
    }
    
    @ViewBuilder
    private func mediaItemCard(url: URL, isSelected: Bool, width: CGFloat, height: CGFloat, onTap: @escaping (() -> Void)) -> some View {
        let width = width
        let height = height
        
        ZStack {
            CNMediaThumbImage(
                url: url,
                size: CGSize(width: width, height: height)
            )
            .clipped()
            .aspectRatio(1, contentMode: .fill)
            
            VStack(alignment: .trailing, spacing: 0) {
                Spacer()
                
                HStack(alignment: .center, spacing: 0) {
                    Spacer()
                    
                    Button {
                        viewModel.selectedImageURL = url
                    } label: {
                        Image(isSelected ? .icSquareCheckedNew : .icSquareUncheckedNew)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 26, height: 26)
                            .clipShape(Rectangle())
                    }
                    .frame(width: 26, height: 26)
                    .clipShape(Rectangle())
                    .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 0)
                    .animation(.easeInOut(duration: 0.1), value: isSelected)
                    .padding(.trailing, 10)
                    .padding(.bottom, 10)
                }
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .onTapGesture(perform: onTap)
    }
}
