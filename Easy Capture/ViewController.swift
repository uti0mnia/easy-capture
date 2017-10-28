//
//  ViewController.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-10-27.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    let cameraCapture = CameraCapture()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PermissionManager.shared.requestCameraPermission() { granted  in
            guard granted else {
                return
            }
            
            self.cameraCapture.start() { success in
                guard success else {
                    return
                }
                
                self.cameraCapture.display(on: self.view, withOrientation: .portrait)
            }
            
        }
    }
    
    
}

