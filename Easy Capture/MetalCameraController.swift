//
//  CameraCapture.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-10-27.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import AVFoundation
import UIKit

protocol MetalCameraControllerDelegate: class {
    func metalCameraController(_ metalCameraController: MetalCameraController, didReciveBufferAsTexture texture: MTLTexture)
    func metalCameraController(_ metalCameraController: MetalCameraController, didFinishRecordingVideoAtURL url: URL)
}

class MetalCameraController: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    public enum CameraCaptureError: Swift.Error {
        case captureSessionNotRunning
        case captureSessionAlreadyRunning
        case invalidInput
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    public enum VideoRecordingError: Swift.Error {
        case noOutputData
        case failedToCreateAVAssetWriter
        case cannotAddAVAssetViewWriter
    }
    
    private enum CameraPosition {
        case front
        case back
    }
    
    private let captureSession = AVCaptureSession()
    
    private var backCamera: AVCaptureDevice?
    private var frontCamera: AVCaptureDevice?
    
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
    private var outputData: AVCaptureVideoDataOutput? {
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
    private let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("movie.mov")
    private var assetWriter: AVAssetWriter?
    private var videoAssetWriter: AVAssetWriterInput?
    
    private var isRecording = false
    
    public var flashMode = AVCaptureDevice.FlashMode.off
    
    public weak var delegate: MetalCameraControllerDelegate?
    
    private var captureQueue = DispatchQueue(label: "com.uti0mnia.easy-capture.metalcameracontroller.capturequeue")
    private var assetWriterQueue = DispatchQueue(label: "com.uti0mnia.easy-capture.metalcameracontroller.assetwriterqueue")
    
    private var metalBufferConverter = MetalBufferConverter()
    
    override init() {
        super.init()
        
        try? FileManager.default.removeItem(at: tempURL)
    }
    
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
    
    public func startRecording() throws {
        do {
            try createAVAsset()
        } catch {
            throw error
        }
        
        isRecording = true
        
    }
    
    public func stopRecording() {
        guard isRecording, let assetWriter = self.assetWriter, let videoAssetWriter = self.videoAssetWriter else {
            return
        }
        
        let currentThreadCall = {
            self.delegate?.metalCameraController(self, didFinishRecordingVideoAtURL: assetWriter.outputURL)
        }
        
        // we use this thread because if the delegate call can be prempted right after checking if isRecording is true, and try to append a buffer
        // after we set videoAssertWritter as finished there;s an error. This is EXTREMELY unlikely but Pete Bhur would be proud.
        assetWriterQueue.async {
            self.isRecording = false
            videoAssetWriter.markAsFinished()
            assetWriter.finishWriting {
                currentThreadCall()
            }
        }
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
        
        // we might not want to do this for recording
        outputData.alwaysDiscardsLateVideoFrames = false
        outputData.setSampleBufferDelegate(self, queue: captureQueue)
        
        if captureSession.canAddOutput(outputData) {
            self.outputData = outputData
        }
    }
    
    private func createAVAsset() throws {
        guard let outputData = outputData else {
            throw VideoRecordingError.noOutputData
        }
        
        do {
            let assetWriter = try AVAssetWriter(outputURL: tempURL, fileType: .mov)
            let settings = outputData.recommendedVideoSettingsForAssetWriter(writingTo: .mov)
            let videoAssetWriter = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
            videoAssetWriter.expectsMediaDataInRealTime = true
            if assetWriter.canAdd(videoAssetWriter) {
                assetWriter.add(videoAssetWriter)
            } else {
                throw VideoRecordingError.cannotAddAVAssetViewWriter
            }
            self.assetWriter = assetWriter
            self.videoAssetWriter = videoAssetWriter
        } catch {
            print("error creating asset writer: \(error.localizedDescription)")
            throw VideoRecordingError.failedToCreateAVAssetWriter
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
    
    private func write(_ sampleBuffer: CMSampleBuffer) {
        guard isRecording, let assetWriter = self.assetWriter, let videoAssetWriter = self.videoAssetWriter else {
            return
        }
        
        guard [AVAssetWriterStatus.unknown, AVAssetWriterStatus.writing].contains(assetWriter.status) else {
            return
        }
        
        if assetWriter.status == .unknown {
            if !assetWriter.startWriting() {
                print("assertWriter error start writing: \(assetWriter.error?.localizedDescription ?? "")")
                return
            }
            assetWriter.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
        }
        
        if videoAssetWriter.isReadyForMoreMediaData {
            videoAssetWriter.append(sampleBuffer)
        }
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // apply filtering to sample buffer if needed
        assetWriterQueue.async {
            self.write(sampleBuffer)
        }
        
        do {
            let texture = try metalBufferConverter.getTexture(sampleBuffer: sampleBuffer)
            connection.videoOrientation = .portrait
            connection.isVideoMirrored = (self.currentCameraPosition == .back) ? false : true
            delegate?.metalCameraController(self, didReciveBufferAsTexture: texture)
        } catch {
            print("Error making texture from buffer: \(error.localizedDescription)")
        }
    }
}









































