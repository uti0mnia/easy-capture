//
//  CameraCapture.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-10-27.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import AVFoundation
import UIKit

protocol MetalCaptureSessionDelegate: class {
    func metalCaptureSession(_ metalCaptureSession: MetalCaptureSession, didReciveBufferAsTexture texture: MTLTexture)
}

class MetalCaptureSession: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
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
    
    private var currentCameraPosition: CameraPosition? {
        didSet {
            guard self.currentCameraPosition != oldValue else {
                return
            }
            
            if self.currentCameraPosition == .back {
                
            } else {
                
            }
        }
    }
    
    private var inputDevice: AVCaptureDeviceInput? {
        didSet {
            if captureSession.isRunning {
                captureSession.beginConfiguration()
            }
            
            if let oldValue = oldValue {
                captureSession.removeInput(oldValue)
            }
            
            if let inputDevice = inputDevice {
                captureSession.addInput(inputDevice)
            }
            
            if captureSession.isRunning {
                captureSession.commitConfiguration()
            }
        }
    }
    private var outputData: AVCaptureVideoDataOutput? {
        didSet {
            if captureSession.isRunning {
                captureSession.beginConfiguration()
            }
            
            if let oldValue = oldValue {
                captureSession.removeOutput(oldValue)
            }
            
            if let outputData = outputData {
                captureSession.addOutput(outputData)
            }
            
            if captureSession.isRunning {
                captureSession.commitConfiguration()
            }
        }
    }
    
    public var flashMode = AVCaptureDevice.FlashMode.off
    
    public weak var delegate: MetalCaptureSessionDelegate?
    
    private var captureQueue = DispatchQueue(label: "CameraCaptureControllerQueue")
    
    private var metalBufferConverter = MetalBufferConverter()
    
    public func start(completion: @escaping (Bool) -> Void) {
        let mainQueueCompletion = { success in
            DispatchQueue.main.async {
                completion(success)
            }
        }
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            mainQueueCompletion(false)
            return
        }
        
        captureQueue.async { [weak self] in
            guard let strongSelf = self else {
                mainQueueCompletion(false)
                return
            }
            
            do {
                strongSelf.captureSession.beginConfiguration()
                try strongSelf.initCaptureDevices()
                strongSelf.initCaptureOutput()
                strongSelf.captureSession.commitConfiguration()
                
                try strongSelf.useCameraIfPossibleInPosition(.back)
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
    
    public func toggleCameraIfPossible() throws {
        guard let currentCameraPosition = self.currentCameraPosition else {
            throw CameraCaptureError.invalidOperation
        }
        
        do {
            switch currentCameraPosition {
            case .back:
                try useCameraIfPossibleInPosition(.front)
            case .front:
                try useCameraIfPossibleInPosition(.back)
            }
        } catch {
            throw error
        }
    }
    
    public func captureImage() {
        // nothing for now.
    }
    
    private func initCaptureDevices() throws {
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
    
    private func initCaptureOutput() {
        let outputData = AVCaptureVideoDataOutput()
        
        outputData.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
        ]
        outputData.alwaysDiscardsLateVideoFrames = true
        outputData.setSampleBufferDelegate(self, queue: captureQueue)
        
        if captureSession.canAddOutput(outputData) {
            captureQueue.async {
                self.outputData = outputData
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
            let input = try AVCaptureDeviceInput(device: camera)
            
            captureQueue.async {
                self.inputDevice = input
            }
            
            currentCameraPosition = position
        } catch {
            print("Couldn't get back camera input \(error.localizedDescription)")
            throw CameraCaptureError.invalidInput
        }
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        do {
            let texture = try metalBufferConverter.getTexture(sampleBuffer: sampleBuffer)
            connection.videoOrientation = .portrait
            connection.isVideoMirrored = (self.currentCameraPosition == .back) ? false : true
            delegate?.metalCaptureSession(self, didReciveBufferAsTexture: texture)
        } catch {
            print("Error making texture from buffer: \(error.localizedDescription)")
        }
    }

}









































