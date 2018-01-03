//
//  CameraController.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-11-24.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import AVFoundation
import Metal

protocol CameraControllerDelegate: class {
    func cameraController(_ cameraController: CameraController, didRenderTexture texture: MTLTexture)
    func cameraController(_ cameraController: CameraController, didReceiveRecordingAt url: URL)
    func cameraController(_ cameraController: CameraController, didReceiveRecordingError error: Error)
}

class CameraController: NSObject, CameraCaptureControllerDelegate, VideoRecorderControllerDelegate {
    
    public weak var delegate: CameraControllerDelegate?
    
    private var texture: MTLTexture?
    
    private var authorized = false
    private(set) var isRecording = false
    
    private let cameraCaptureController = CameraCaptureController()
    private lazy var videoRecorderController: VideoRecorderController = {
        let recorder = VideoRecorderController()
        recorder.delegate = self
        return recorder
    }()    
    private lazy var metalBufferConverter = MetalBufferConverter()
    private lazy var metalTextureConverter = MetalTextureConverter()
    
    public func startCaptureSession(completion: @escaping (Bool) -> Void) {
        guard cameraCaptureController.status != .running else {
            completion(true)
            return
        }
        
        PermissionManager.shared.cameraPermission() { granted in
            guard granted else {
                return
            }
            
            self.authorized = true
            do {
                try self.cameraCaptureController.start()
                self.cameraCaptureController.delegate = self
                completion(true)
            } catch {
                print("Error getting capture controller: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    public func stopCaptureSession() {
        cameraCaptureController.stop()
    }
    
    public func takePicture() -> CGImage? {
        guard authorized, let texture = self.texture else {
            print("texture is nil")
            return nil
        }
        
        return metalTextureConverter.convertToCGImage(texture)
    }
    
    public func startRecording()-> Bool {
        guard authorized, let output = cameraCaptureController.outputData else {
            return false
        }
        
        do {
            try videoRecorderController.startRecording(fromOutput: output)
            isRecording = true
        } catch {
            print("could't start recording: \(error.localizedDescription)")
            return false
        }
        
        return true
    }
    
    public func stopRecording() {
        videoRecorderController.stopRecording()
        isRecording = false
    }
    
    public func toggleCamera() {
        guard !isRecording else {
            // TODO: Handle swapping camera while recording
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            try? self.cameraCaptureController.toggleCameraIfPossible()
        }
    }
    
    @discardableResult
    public func changeZoom(percent: CGFloat) -> CGFloat {
        cameraCaptureController.zoom *= percent
        return cameraCaptureController.zoom
    }
    
    // MARK: - CameraCaptureControllerDelegate
    
    func cameraCaptureController(_ cameraCaptureController: CameraCaptureController, didRecieveSampleBuffer sampleBuffer: CMSampleBuffer) {
        if isRecording {
            DispatchQueue.global(qos: .userInitiated).async {
                self.videoRecorderController.write(sampleBuffer)
            }
        }
        
        do {
            self.texture = try metalBufferConverter.getTexture(sampleBuffer: sampleBuffer)
            delegate?.cameraController(self, didRenderTexture: self.texture!)
        } catch {
            print("Error rendering texture: \(error.localizedDescription)")
        }
    }
    
    // MARK: - VideoRecorderControllerDelegate
    
    func videoRecorderController(_ videoRecorderController: VideoRecorderController, didFinishRecordingVideoAt url: URL) {
        DispatchQueue.main.async {
            self.delegate?.cameraController(self, didReceiveRecordingAt: url)
        }
        
    }
    
    func videoRecorderController(_ videoRecorderController: VideoRecorderController, didStopRecordingWithError error: Error) {
        DispatchQueue.main.async {
            self.delegate?.cameraController(self, didReceiveRecordingError: error)
        }
    }
    
}
