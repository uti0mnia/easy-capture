//
//  ViewController.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-10-27.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

class MainViewController: MetalCaptureViewController, CameraOptionsViewDelegate {
    

    private var recordButton: UIButton?
    private var cameraOptionsView = CameraOptionsView()
    
    var isRecording = false
    
    lazy private var capturePreviewVC = CapturePreviewViewController()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVisuals()
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
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
        
        cameraOptionsView.delegate = self
        view.addSubview(cameraOptionsView)
        cameraOptionsView.snp.makeConstraints() { make in
            make.top.left.right.equalToSuperview().inset(Layout.padding)
            make.height.equalTo(Layout.optionViewHeight)
        }
    }
    
    @objc private func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        try? metalCameraController.toggleCameraIfPossible()
    }
    
    @objc private func capturePicture(_ sender: UIButton) {
//        // TODO - move to class + use different colour types
//        guard let texture = self.texture, let cgimage = MetalTextureConverter.shared.convertToCGImage(texture) else {
//            print("Couldn't create cgimage from texture")
//            return
//        }
//
//        let image = UIImage(cgImage: cgimage)
//        capturePreviewVC.imageView.image = image
//
//        present(capturePreviewVC, animated: false, completion: nil)
        
//        isRecording ? metalCameraController.stopRecording() : try? metalCameraController.startRecording()
//        isRecording = !isRecording
    }
    
    // MARK: - CameraOptionsViewDelegate
    
    
    func cameraOptionsViewDidSelectCamera(_ cameraOptionsView: CameraOptionsView) {
        cameraOptionsView.setCameraMode()
    }
    
    func cameraOptionsViewDidSelectVideo(_ cameraOptionsView: CameraOptionsView) {
        cameraOptionsView.setVideoMode()
    }
    
    func cameraOptionsViewDidSelectToggleFlash(_ cameraOptionsView: CameraOptionsView) {
        // nothing
    }
    
    func cameraOptionsViewDidSelectToggleCamera(_ cameraOptionsView: CameraOptionsView) {
        try? metalCameraController.toggleCameraIfPossible()
    }
    
}




























