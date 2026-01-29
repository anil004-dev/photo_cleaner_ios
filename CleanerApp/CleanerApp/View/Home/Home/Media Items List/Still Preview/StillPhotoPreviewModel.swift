//
//  StillPhotoPreviewModel.swift
//  CleanerApp
//
//  Created by iMac on 28/01/26.
//

import Combine
import Foundation

class StillPhotoPreviewModel: ObservableObject {
    
    let arrImageURLs: [URL]
    @Published var selectedImageURL: URL
    var onSaveAction: ((URL) -> Void)?
    
    init(arrImageURLs: [URL]) {
        self.arrImageURLs = arrImageURLs
        self.selectedImageURL = arrImageURLs[1]
    }
}
