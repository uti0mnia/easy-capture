//
//  VideoRecorderController.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-11-18.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import AVFoundation
import Foundation

protocol VideoRecorderControllerDelegate: class {
    func videoRecorderController(_ videoRecorderController: VideoRecorderController, didFinishRecordingVideoAt url: URL)
    func videoRecorderController(_ videoRecorderController: VideoRecorderController, didStopRecordingWithError error: Error)
}

class VideoRecorderController: NSObject {
    public enum VideoRecorderControllerStatus {
        case unknown
        case ready
        case recording
        case error
    }
    
    public enum RecordingError: Swift.Error {
        case failedToCreateAVAssetWriter
        case cannotAddAVAssetViewWriter
        case avAssetWriterWrongState
        case recorderNotReady
    }
    
    public weak var delegate: VideoRecorderControllerDelegate?
    
    private(set) var status = VideoRecorderControllerStatus.ready
    
    private let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("movie.mov")
    
    private var assetWriter: AVAssetWriter?
    private var videoAssetWriter: AVAssetWriterInput?
    
    private var assetWriterQueue = DispatchQueue(label: "com.uti0mnia.easy-capture.metalcameracontroller.assetwriterqueue")
    
    
    
    public func startRecording(fromOutput output: AVCaptureVideoDataOutput) throws {
        guard status == .ready else {
            throw RecordingError.recorderNotReady
        }
        
        try? FileManager.default.removeItem(at: tempURL) // delete item at tempURL if it's there
        
        do {
            let assetWriter = try AVAssetWriter(outputURL: tempURL, fileType: .mov)
            
            let settings = output.recommendedVideoSettingsForAssetWriter(writingTo: .mov)
            let videoAssetWriter = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
            videoAssetWriter.expectsMediaDataInRealTime = true
            videoAssetWriter.transform = OrientationHelper.shared.getAssetWriterAffineTransform()
            
            if assetWriter.canAdd(videoAssetWriter) {
                assetWriter.add(videoAssetWriter)
            } else {
                throw RecordingError.cannotAddAVAssetViewWriter
            }
            
            self.assetWriter = assetWriter
            self.videoAssetWriter = videoAssetWriter
            self.status = .recording
        } catch {
            print("error creating asset writer: \(error.localizedDescription)")
            throw RecordingError.failedToCreateAVAssetWriter
        }
    }
    
    public func write(_ sampleBuffer: CMSampleBuffer) {
        guard status == .recording, let assetWriter = self.assetWriter, let videoAssetWriter = self.videoAssetWriter else {
            return
        }
        
        guard assetWriter.status == AVAssetWriterStatus.unknown || assetWriter.status ==  AVAssetWriterStatus.writing else {
            status = .error
            delegate?.videoRecorderController(self, didStopRecordingWithError: RecordingError.avAssetWriterWrongState)
            stopRecording()
            return
        }
        
        // we start the asset writer when we get the first frame so the timing is correct.
        assetWriterQueue.async {
            if assetWriter.status == .unknown {
                if !assetWriter.startWriting() {
                    print("assertWriter error start writing: \(assetWriter.error?.localizedDescription ?? "")")
                    self.status = .error
                    self.stopRecording()
                    return
                }
                
                assetWriter.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
            }
            
            if videoAssetWriter.isReadyForMoreMediaData {
                videoAssetWriter.append(sampleBuffer)
            }
        }
    }
    
    public func stopRecording() {
        guard let assetWriter = self.assetWriter, let videoAssetWriter = self.videoAssetWriter else {
            return
        }
        
        let currentThreadCall = {
            if self.status == VideoRecorderControllerStatus.recording {
                self.delegate?.videoRecorderController(self, didFinishRecordingVideoAt: assetWriter.outputURL)
            }
        }
        
        assetWriterQueue.async {
            videoAssetWriter.markAsFinished()
            assetWriter.finishWriting {
                currentThreadCall()
                
                self.reset()
            }
        }
    }
    
    private func reset() {
        videoAssetWriter = nil
        assetWriter = nil
        
        status = .ready
    }
}
