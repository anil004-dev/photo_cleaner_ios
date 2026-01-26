//
//  PHAsset + Custom.swift
//  CleanerApp
//
//  Created by iMac on 26/01/26.
//

import Photos

extension PHAsset {
    
    func fileSizeAsync(completion: (Int64) -> Void) {
        
        let resources = PHAssetResource.assetResources(for: self)
        
        guard let resource = resources.first else {
            completion(0)
            return
        }
        
        let fileSize = resource.value(forKey: "fileSize") as? Int64
        
        completion(fileSize ?? 0)
        return
    }
    
    func fileSizeSync() -> Int64 {
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var result: Int64 = 0
        
        self.fileSizeAsync { size in
            result = size
            semaphore.signal()
        }
        
        semaphore.wait()
        
        return result
    }
}
