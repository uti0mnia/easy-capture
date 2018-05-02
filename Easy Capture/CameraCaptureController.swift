//
//  MetalAVController.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-11-17.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import AVFoundation

protocol CameraCaptureControllerDelegate: class {
    func cameraCaptureController(_ cameraCaptureController: CameraCaptureController, didRecieveSampleBuffer sampleBuffer: CMSampleBuffer)
}

class CameraCaptureController: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    public enum CameraCaptureError: Swift.Error {
        case unauthorized
        case captureSessionNotRunning
        case captureSessionAlreadyRunning
        case invalidInput
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    public enum CameraCaptureStatus {
        case ready
        case running
        case stopped
        case unauthorized
        case error
        case unknown
    }
    
    private enum CameraPosition {
        case front
        case back
    }
    
    public weak var delegate: CameraCaptureControllerDelegate?
    
    private let captureSession = AVCaptureSession()
    
    private var backCamera: AVCaptureDevice?
    private var frontCamera: AVCaptureDevice?
    private var currentCamera: AVCaptureDevice? {
        return (currentCameraPosition == CameraPosition.back) ? backCamera : frontCamera
    }
    
    private var currentCameraPosition: CameraPosition?
    
    private var inputDevice: AVCaptureDeviceInput? {
        didSet {
            captureSession.beginConfiguration()
            if let oldValue = oldValue {
                captureSession.removeInput(oldValue)
            }
            if let inputDevice = inputDevice {
                captureSession.addInput(inputDevice)
            }
            captureSession.commitConfiguration()
        }
    }
    private(set) var outputData: AVCaptureVideoDataOutput? {
        didSet {
            captureSession.beginConfiguration()
            if let oldValue = oldValue {
                captureSession.removeOutput(oldValue)
            }
            if let outputData = outputData {
                captureSession.addOutput(outputData)
            }
            captureSession.commitConfiguration()
        }
    }
    
    public var flashMode = AVCaptureDevice.FlashMode.off
    public var zoom: CGFloat = 1.0 {
        didSet {
            guard let currentCamera = currentCamera else {
                print("No current camera for zoom")
                return
            }
            if zoom > currentCamera.activeFormat.videoMaxZoomFactor {
                zoom = currentCamera.activeFormat.videoMaxZoomFactor
            } else if zoom < 1 {
                zoom = 1
            }
            do {
                try currentCamera.lockForConfiguration()
                currentCamera.videoZoomFactor = zoom
                currentCamera.unlockForConfiguration()
            } catch {
                print("Error locking config")
            }
        }
    }
    
    private(set) var status: CameraCaptureStatus = .unknown
    
    private var captureQueue = DispatchQueue(label: "com.uti0mnia.easy-capture.cameracapturecontroller.capturequeue")
    
    override init() {
        super.init()
        
        do {
            captureSession.beginConfiguration()
            try initCaptureDevices()
            initCaptureOutput()
            captureSession.commitConfiguration()
            try useCameraIfPossibleInPosition(.back)
            
            status = .ready
        } catch {
            print("error starting camera session: \(error.localizedDescription)")
            status = .error
        }
        
        addNotifications()
    }
    
    deinit {
        removeNotifications()
    }
    
    public func start() throws {
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            status = .unauthorized
            throw CameraCaptureError.unauthorized
        }
        
        if status == .ready {
            captureQueue.async {
                self.captureSession.startRunning()
            }
        } else {
            throw CameraCaptureError.unknown
        }
    }
    
    public func stop() {
        if status == .running {
            captureQueue.async {
                self.captureSession.stopRunning()
                self.status = .ready
            }
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
    
    private func initCaptureDevices() throws {
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        let cameras = session.devices.compactMap({ $0 })
        
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
        
        outputData.alwaysDiscardsLateVideoFrames = false
        outputData.setSampleBufferDelegate(self, queue: captureQueue)
        
        if captureSession.canAddOutput(outputData) {
            self.outputData = outputData
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
        connection.videoOrientation = .portrait // TODO: figure out how to do this shit correctly
        connection.isVideoMirrored = (currentCameraPosition == .back) ? false : true // TODO: how to do this better
        delegate?.cameraCaptureController(self, didRecieveSampleBuffer: sampleBuffer)
    }
    
    // MARK: - Notifications
    
    private func addNotifications() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(captureSessionDidStartRunning(_:)), name: .AVCaptureSessionDidStartRunning, object: nil)
        nc.addObserver(self, selector: #selector(captureSessionDidStopRunning(_:)), name: .AVCaptureSessionDidStopRunning, object: nil)
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: .AVCaptureSessionDidStartRunning, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVCaptureSessionDidStopRunning, object: nil)
    }
    
    @objc private func captureSessionDidStartRunning(_ notification: Notification) {
        self.status = .running
    }
    
    @objc private func captureSessionDidStopRunning(_ notification: Notification) {
        self.status = .stopped
    }
}







































