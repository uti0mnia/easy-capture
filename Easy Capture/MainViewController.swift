//
//  ViewController.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-10-27.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import UIKit
import AVFoundation

class MainViewController: MetalCaptureViewController {

    private var recordButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVisuals()
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func initVisuals() {
        let frame = CGRect(x: (view.bounds.width - Layout.recordButtonSize.width) / 2,
                           y: view.bounds.height - Layout.recordButtonSize.height - Layout.padding,
                           width: Layout.recordButtonSize.width,
                           height: Layout.recordButtonSize.height)
        recordButton = UIButton(frame: frame)
        recordButton?.setImage(#imageLiteral(resourceName: "record"), for: .normal)
        recordButton?.addTarget(self, action: #selector(capturePicture(_:)), for: .touchUpInside)
        
        view.addSubview(recordButton!)
    }
    
    @objc private func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        try? metalCaptureSession.toggleCameraIfPossible()
    }
    
    @objc private func capturePicture(_ sender: UIButton) {
//        cameraController.captureImage()
    }
    
}




























