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

class MainViewController: MetalCaptureViewController, CameraStatusBarViewDelegate, CameraControllerDelegate {
    
    public enum CameraMode {
        case photo
        case video
    }
    
    private var recordImage = UIImageView()
    private var cameraStatusBarView = CameraStatusBarView()
    
    lazy private var capturePreviewVC = CapturePreviewViewController()
    lazy private var videoPreviewVC = VideoPreviewViewController()
    
    private let cameraController = CameraController()
    
    private var mode = CameraMode.video
    
    private var videoTimer: Timer?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setVisuals()
        addConstraints()
        addGestures()
        
        cameraController.startRenderingTextures() { success in
            guard success else {
                self.displayError(message: "Issue starting camera... This shouldn't happen.")
                return
            }
            
            self.cameraController.delegate = self
        }
    }
    
    private func setVisuals() {
        recordImage.image = #imageLiteral(resourceName: "record")
        recordImage.contentMode = .scaleAspectFit
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapRecordButton(_:)))
        recordImage.isUserInteractionEnabled = true
        recordImage.addGestureRecognizer(tap)
        view.addSubview(recordImage)
        
        cameraStatusBarView.delegate = self
        view.addSubview(cameraStatusBarView)
        
        if mode == .photo {
            cameraStatusBarView.setCameraMode()
        } else {
            cameraStatusBarView.setVideoMode()
        }
    }
    
    private func addConstraints() {
        cameraStatusBarView.snp.makeConstraints() { make in
            make.top.left.right.equalToSuperview().inset(Layout.padding)
            make.height.equalTo(Layout.optionViewHeight)
        }
        
        recordImage.snp.makeConstraints() { make in
            make.bottom.equalToSuperview().offset(-Layout.padding)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(Layout.recordButtonSide)
        }
    }
    
    private func addGestures() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
    }
    
    @objc private func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        try? cameraCaptureController.toggleCameraIfPossible()
    }
    
    @objc private func didTapRecordButton(_ sender: UITapGestureRecognizer) {
        switch mode {
        case .photo:
            takePicture()
        case .video:
            if cameraController.isRecording {
                stopRecording()
            } else {
                startRecording()
            }
        }
    }
    
    private func takePicture() {
        // TODO - move to class + use different colour types
        guard let cgimage = cameraController.takePicture() else {
            return
        }
        
        capturePreviewVC.imageView.image = UIImage(cgImage: cgimage)
        
        present(capturePreviewVC, animated: false, completion: nil)
    }
    
    private func startRecording() {
        cameraController.startRecording()
    }
    
    private func stopRecording() {
        cameraController.stopRecording()
    }
    
    // MARK: - CameraOptionsViewDelegate
    
    
    func cameraOptionsViewDidSelectCamera(_ cameraOptionsView: CameraStatusBarView) {
        cameraOptionsView.setCameraMode()
    }
    
    func cameraOptionsViewDidSelectVideo(_ cameraOptionsView: CameraStatusBarView) {
        cameraOptionsView.setVideoMode()
    }
    
    func cameraOptionsViewDidSelectToggleFlash(_ cameraOptionsView: CameraStatusBarView) {
        // nothing
    }
    
    func cameraOptionsViewDidSelectToggleCamera(_ cameraOptionsView: CameraStatusBarView) {
        try? cameraCaptureController.toggleCameraIfPossible()
    }
    
    // MARK: - CameraControllerDelegate
    
    func cameraController(_ cameraController: CameraController, didRenderTexture texture: MTLTexture) {
        self.texture = texture
    }
    
    func cameraController(_ cameraController: CameraController, didReceiveRecordingAt url: URL) {
        videoPreviewVC.url = url
        self.present(videoPreviewVC, animated: true, completion: nil)
    }
    
    func cameraController(_ cameraController: CameraController, didReceiveRecordingError error: Error) {
        displayError(message: "There was a problem recording the video...")
        print("Error recording: \(error.localizedDescription)")
    }
    
}




























