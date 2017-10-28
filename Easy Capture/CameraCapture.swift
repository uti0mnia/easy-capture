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
    public enum CameraPosition {
        case front
        case back
    }
    
    private var captureSession: AVCaptureSession?
    
    private var backCamera: AVCaptureDevice?
    private var frontCamera: AVCaptureDevice?
    
    private var currentCameraPosition: CameraPosition?
    private var frontCameraInput: AVCaptureDeviceInput?
    private var backCameraInput: AVCaptureDeviceInput?
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    public func start(completion: @escaping (Bool) -> Void) {
        DispatchQueue(label: "start").async { [weak self] in
            guard let strongSelf = self else {
                completion(false)
                return
            }
            
            strongSelf.captureSession = AVCaptureSession()
            strongSelf.configureCaptureDevices()?.configureCameraInputs()
            DispatchQueue.main.async {
                completion(strongSelf.currentCameraPosition != nil)
            }
        }
    }
    
    public func display(on view: UIView, withOrientation orientation: AVCaptureVideoOrientation ) {
        guard let captureSession = self.captureSession, captureSession.isRunning else {
            print("Capture session nil or not running")
            return
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = .resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = orientation
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.bounds
    }
    
    @discardableResult
    private func configureCaptureDevices() -> CameraCapture? {
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        let cameras = session.devices.flatMap({ $0 })
        
        if cameras.isEmpty {
            print("No capture devices")
            return nil
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
        
        return self
    }
    
    @discardableResult
    private func configureCameraInputs() -> CameraCapture? {
        guard let captureSession = captureSession else {
            print("Nil capture session")
            return nil
        }
        
        if let backCamera = self.backCamera {
            do {
                let input = try AVCaptureDeviceInput(device: backCamera)
                self.backCameraInput = input
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
                
                self.currentCameraPosition = .back
            } catch {
                print("Couldn't get back camera input \(error.localizedDescription)")
                return nil
            }
            
        } else if let frontCamera = self.frontCamera {
            do {
                let input = try AVCaptureDeviceInput(device: frontCamera)
                self.frontCameraInput = input
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
                self.currentCameraPosition = .front
            } catch {
                print("Couldn't get front camera input \(error.localizedDescription)")
                return nil
            }
        } else {
            print("No cameras available")
            return nil
        }
        
        captureSession.startRunning()
        return self
    }
}









































