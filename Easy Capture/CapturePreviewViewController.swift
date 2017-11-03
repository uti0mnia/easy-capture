//
//  CapturePreviewViewController.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-10-28.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import UIKit

class CapturePreviewViewController: UIViewController {
    
    private(set) var imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.contentMode = .scaleAspectFit
        imageView.frame = view.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    
    
}
