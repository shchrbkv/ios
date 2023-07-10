//
//  ImageSaver.swift
//  HotProspects
//
//  Created by Alex Scherbakov on 4/13/23.
//

import UIKit

class ImageSaver: NSObject {
    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?

    // MARK: Internal

    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc
    func saveCompleted(
        _ image: UIImage,
        didFinishSavingWithError error: Error?,
        contextInfo: UnsafeRawPointer) {
        if let error {
            errorHandler?(error)
        } else {
            successHandler?()
        }
    }
}
