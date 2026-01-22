//
//  CNMediaThumbImage.swift
//  CleanerApp
//
//  Created by iMac on 05/12/25.
//

import SwiftUI
import SDWebImageSwiftUI
import Photos

struct CNMediaThumbImage: View {
    let mediaItem: MediaItem
    let size: CGSize
    var contentMode: ContentMode = .fill
    
    var body: some View {
        let thumbnailSize = CGSize(width: size.width * 2, height: size.height * 2)
        
        WebImage(
            url: mediaItem.thumbnailURL,
            context: [
                .imageThumbnailPixelSize: thumbnailSize,
                .imageScaleFactor : UIScreen.main.scale
            ]
        )
        .resizable()
        .cancelOnDisappear(true)
        .aspectRatio(contentMode: contentMode)
        .if(contentMode == .fill) { view in
            view.scaledToFill()
        }
        .if(contentMode == .fit) { view in
            view.scaledToFit()
        }
        .frame(width: size.width, height: size.height)
    }
}
