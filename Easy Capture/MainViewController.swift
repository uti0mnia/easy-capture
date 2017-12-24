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
    private static let startCameraErrorMessage = "Issue starting camera... This shouldn't happen."
    private static let flashTime: TimeInterval = 0.3
    
    public enum CameraMode {
        case photo
        case video
    }
    
    private var recordImage = UIImageView()
    private var cameraStatusBarView = CameraStatusBarView()
    
    private var flashView = UIView()
    
    lazy private var capturePreviewVC = CapturePreviewViewController()
    lazy private var videoPreviewVC = VideoPreviewViewController()
    
    private let cameraController = CameraController()
    
    private var mode = CameraMode.video
    
    private var videoTimer: Timer?
    private var timeParts = SimpleTimeParts()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setVisuals()
        addConstraints()
        addGestures()
        addObservers()
        
        self.cameraController.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        cameraController.stopCaptureSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraController.startCaptureSession() { success in
            if !success {
                self.displayError(message: MainViewController.startCameraErrorMessage)
            }
        }
    }
    
    deinit {
        removeObservers()
        stopTimer()
    }
    
    private func setVisuals() {
        flashView.backgroundColor = Colours.flashColour
        flashView.alpha = 0
        flashView.frame = view.bounds
        flashView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(flashView)
        
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
        cameraController.toggleCamera()
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
        guard let cgimage = cameraController.takePicture() else {
            print("picture was nil")
            return
        }
        
        capturePreviewVC.imageView.image = UIImage(cgImage: cgimage)
        showScreenFlash {
            self.present(self.capturePreviewVC, animated: false, completion: nil)
        }
    }
    
    private func startRecording() {
        cameraController.startRecording()
        
        videoTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.cameraStatusBarView.timerLabel.text = self.timeParts.shortString
            self.timeParts.seconds += 1
        }
        videoTimer?.fire()
        
    }
    
    private func stopRecording() {
        cameraController.stopRecording()
        
        stopTimer()
    }
    
    private func stopTimer() {
        videoTimer?.invalidate()
        videoTimer = nil
    }
    
    private func showScreenFlash(completion: @escaping () -> Void) {
        flashView.alpha = 1
        
        UIView.animate(withDuration: MainViewController.flashTime, animations: {
            self.flashView.alpha = 0
        }) {_ in
            completion()
        }
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillMoveToBackground(_:)), name: .UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillMoveToForeground(_:)), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    // MARK: - CameraOptionsViewDelegate
    
    
    func cameraOptionsViewDidSelectCamera(_ cameraOptionsView: CameraStatusBarView) {
        cameraOptionsView.setCameraMode()
        cameraOptionsView.timerLabel.isHidden = true
        
        mode = .photo
    }
    
    func cameraOptionsViewDidSelectVideo(_ cameraOptionsView: CameraStatusBarView) {
        cameraOptionsView.setVideoMode()
        cameraOptionsView.timerLabel.isHidden = false
        
        mode = .video
    }
    
    func cameraOptionsViewDidSelectToggleFlash(_ cameraOptionsView: CameraStatusBarView) {
        // nothing
    }
    
    func cameraOptionsViewDidSelectToggleCamera(_ cameraOptionsView: CameraStatusBarView) {
        cameraController.toggleCamera()
    }
    
    // MARK: - CameraControllerDelegate
    
    func cameraController(_ cameraController: CameraController, didRenderTexture texture: MTLTexture) {
        self.texture = texture
    }
    
    func cameraController(_ cameraController: CameraController, didReceiveRecordingAt url: URL) {
        videoPreviewVC.url = url
        self.present(videoPreviewVC, animated: false, completion: nil)
        cameraStatusBarView.timerLabel.text = "00:00"
    }
    
    func cameraController(_ cameraController: CameraController, didReceiveRecordingError error: Error) {
        displayError(message: "There was a problem recording the video...")
        print("Error recording: \(error.localizedDescription)")
    }
    
    
    // MARK: - Notifications
    
    @objc private func applicationWillMoveToBackground(_ notification: Notification) {
        if cameraController.isRecording {
            cameraController.stopRecording()
            stopTimer()
        }
        
        cameraController.stopCaptureSession()
    }
    
    @objc private func applicationWillMoveToForeground(_ notification: Notification) {
        cameraController.startRecording()
    }
}




























