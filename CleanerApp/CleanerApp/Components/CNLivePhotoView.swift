//
//  CNLivePhotoView.swift
//  CleanerApp
//
//  Created by iMac on 08/12/25.
//

import PhotosUI
import SwiftUI

struct CNLivePhotoView: UIViewRepresentable {
    let livePhoto: PHLivePhoto
    
    func makeUIView(context: Context) -> PHLivePhotoView {
        let view = PHLivePhotoView()
        view.contentMode = .scaleAspectFit
        return view
    }
    
    func updateUIView(_ uiView: PHLivePhotoView, context: Context) {
        uiView.livePhoto = livePhoto
        uiView.startPlayback(with: .hint)
    }
}
