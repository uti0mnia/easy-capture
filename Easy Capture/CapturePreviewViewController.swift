//
//  CapturePreviewViewController.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-10-28.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import UIKit

class CapturePreviewViewController: PreviewViewController {
    
    public let imageView = UIImageView()
    
    private var saveHandler: ((Bool) -> Void)?
    
    public var imageOrientation = UIImageOrientation.up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        imageView.frame = self.view.bounds
        imageView.contentMode = .scaleAspectFit
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.insertSubview(imageView, at: 0)
    }
    
    public override func handleSave(completion: @escaping (Bool) -> Void) {
        guard let cgImage = imageView.image?.cgImage else {
            completion(false)
            return
        }
        
        saveHandler = completion
        let imageToSave = UIImage(cgImage: cgImage, scale: 1.0, orientation: imageOrientation)
        UIImageWriteToSavedPhotosAlbum(imageToSave, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        if let error = error {
            print("Error saving image: \(error.localizedDescription)")
            saveHandler?(false)
        } else {
            saveHandler?(true)
        }
        
    }
}





































