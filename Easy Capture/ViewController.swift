//
//  ViewController.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-10-27.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    private let cameraCapture = CameraCapture()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initCamera()
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func initCamera() {
        PermissionManager.shared.requestCameraPermission() { granted  in
            guard granted else {
                return
            }
            
            self.cameraCapture.start() { success in
                guard success else {
                    // handle error here
                    return
                }
                
                self.cameraCapture.display(on: self.view, withOrientation: .portrait)
            }
            
        }
    }
    
    @objc private func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        try? cameraCapture.toggleCameraIfPossible()
    }
    
    
}

