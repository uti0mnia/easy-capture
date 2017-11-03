//
//  CameraCapture.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-10-27.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import AVFoundation
import UIKit

protocol CameraCaptureControllerDelegate: class {
    func cameraCaptureController(_ cameraCaptureController: CameraCaptureController, didRecieveSampleBuffer photoSampleBuffer: CMSampleBuffer?, withPreview previewSampleBuffer: CMSampleBuffer?, error: Error?)
    
    func cameraCaptureController(_ cameraCaptureController: CameraCaptureController, didReciveVideBuffer buffer: CMSampleBuffer?)
}

class CameraCaptureController: NSObject, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    public enum CameraCaptureError: Swift.Error {
        case captureSessionNotRunning
        case captureSessionAlreadyRunning
        case invalidInput
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    public enum CameraPosition {
        case front
        case back
    }
    
    private let captureSession = AVCaptureSession()
    
    private var backCamera: AVCaptureDevice?
    private var frontCamera: AVCaptureDevice?
    
    private var currentCameraPosition: CameraPosition?
    
    private var frontCameraInput: AVCaptureDeviceInput?
    private var backCameraInput: AVCaptureDeviceInput?
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    private let photoOutput = AVCapturePhotoOutput()
    private let outputData = AVCaptureVideoDataOutput()
    
    public var flashMode = AVCaptureDevice.FlashMode.off
    
    public weak var delegate: CameraCaptureControllerDelegate?
    
    private var captureQueue = DispatchQueue(label: "cameraCaptureControllerQueue")
    
    public func start(completion: @escaping (Bool) -> Void) {
        let mainQueueCompletion = { success in
            DispatchQueue.main.async {
                completion(success)
            }
        }
        
        captureQueue.async { [weak self] in
            guard let strongSelf = self else {
                mainQueueCompletion(false)
                return
            }
            
            do {
                try strongSelf.configureCaptureDevices()
                try strongSelf.useBackCameraIfPossible()
                strongSelf.configureCaptureOutput()
                strongSelf.captureSession.startRunning()
                
                mainQueueCompletion(true)
            } catch {
                print("error starting camera session: \(error.localizedDescription)")
                mainQueueCompletion(false)
            }
        }
    }
    
    public func stop() {
        captureQueue.async {
            self.captureSession.stopRunning()
        }
    }
    
    public func display(on view: UIView, withOrientation orientation: AVCaptureVideoOrientation ) {
        guard captureSession.isRunning else {
            print("Capture session nil or not running")
            return
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = .resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = orientation
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.bounds
    }
    
    public func toggleCameraIfPossible() throws {
        guard let currentCameraPosition = self.currentCameraPosition else {
            throw CameraCaptureError.invalidOperation
        }
        
        do {
            switch currentCameraPosition {
            case .back:
                try useFrontCameraIfPossible()
            case .front:
                try useBackCameraIfPossible()
            }
        } catch {
            throw error
        }
    }
    
    public func captureImage() {
        guard captureSession.isRunning else {
            delegate?.cameraCaptureController(self, didRecieveSampleBuffer: nil, withPreview: nil, error: CameraCaptureError.captureSessionNotRunning)
            return
        }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = self.flashMode
        settings.isHighResolutionPhotoEnabled = true
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    private func configureCaptureDevices() throws {
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        let cameras = session.devices.flatMap({ $0 })
        
        if cameras.isEmpty {
            print("No capture devices")
            throw CameraCaptureError.noCamerasAvailable
        }
        
        cameras.forEach() { camera in
            switch camera.position {
            case .front:
                frontCamera = camera
            case .back:
                backCamera = camera
                do {
                    try camera.lockForConfiguration()
                    camera.focusMode = .continuousAutoFocus
                    camera.unlockForConfiguration()
                } catch {
                    print("Unable to lock camera for configuration: \(error.localizedDescription)")
                }
            default:
                break
            }
        }
        
    }
    
    private func configureCaptureOutput() {
        let settings = [AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecJPEG])]
        photoOutput.setPreparedPhotoSettingsArray(settings, completionHandler: nil)
        
        outputData.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
        ]
        
        let captureSessionQueue = DispatchQueue(label: "CameraSessionQueue", attributes: [])
        outputData.setSampleBufferDelegate(self, queue: captureSessionQueue)
        
        captureSession.beginConfiguration()
        
        if captureSession.canAddOutput(outputData) {
            captureSession.addOutput(outputData)
        }
        captureSession.commitConfiguration()
    }
    
    private func useCameraIfPossibleInPosition(_ position: CameraPosition) throws {
        if currentCameraPosition == position {
            print("camera already in position \(position)")
            return
        }
        
        guard let camera = (position == .back) ? backCamera : frontCamera else {
            throw CameraCaptureError.noCamerasAvailable
        }
        
        do {
            captureSession.beginConfiguration()
            
            if let currentInput = (currentCameraPosition == .back) ? backCameraInput : frontCameraInput {
                captureSession.removeInput(currentInput)
            }
            
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            captureSession.commitConfiguration()
            
            if position == .front {
                frontCameraInput = input
            } else {
                backCameraInput = input
            }
            
            currentCameraPosition = position
        } catch {
            print("Couldn't get back camera input \(error.localizedDescription)")
            throw CameraCaptureError.invalidInput
        }
    }
    
    private func useBackCameraIfPossible() throws {
        do {
            try useCameraIfPossibleInPosition(.back)
        } catch {
            throw error
        }
    }
    
    private func useFrontCameraIfPossible() throws {
        do {
            try useCameraIfPossibleInPosition(.front)
        } catch {
            throw error
        }
    }
    
    // MARK: - AVCapturePhotoCaptureDelegate
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        delegate?.cameraCaptureController(self, didRecieveSampleBuffer: photoSampleBuffer, withPreview: previewPhotoSampleBuffer, error: error)
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.cameraCaptureController(self, didReciveVideBuffer: sampleBuffer)
    }
}









































