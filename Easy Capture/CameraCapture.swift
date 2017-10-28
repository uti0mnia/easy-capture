//
//  CameraCapture.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-10-27.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import AVFoundation
import UIKit

class CameraCapture {
    
    public enum CameraCaptureError: Swift.Error {
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
    
    private var captureSession = AVCaptureSession()
    
    private var backCamera: AVCaptureDevice?
    private var frontCamera: AVCaptureDevice?
    
    private var currentCameraPosition: CameraPosition?
    
    private var frontCameraInput: AVCaptureDeviceInput?
    private var backCameraInput: AVCaptureDeviceInput?
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    public func start(completion: @escaping (Bool) -> Void) {
        
        let mainQueueCompletion = { success in
            DispatchQueue.main.async {
                completion(success)
            }
        }
        
        DispatchQueue(label: "start").async { [weak self] in
            guard let strongSelf = self else {
                mainQueueCompletion(false)
                return
            }
            
            do {
                try strongSelf.configureCaptureDevices()
                try strongSelf.useBackCameraIfPossible()
                strongSelf.captureSession.startRunning()
                
                mainQueueCompletion(true)
            } catch {
                print("error starting camera session: \(error.localizedDescription)")
                mainQueueCompletion(false)
            }
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
}









































