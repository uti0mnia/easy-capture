//
//  MetalBufferConverter.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-10-30.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import AVFoundation
import Metal

protocol MetalBufferConverterDelegate: class {
    func metalBufferConverter(_ metalBufferConverter: MetalBufferConverter, didCreateTexture texture: MTLTexture)
}

class MetalBufferConverter: NSObject, CameraCaptureControllerDelegate {
    
    private let cameraController = CameraCaptureController()

    private var textureCache: CVMetalTextureCache?
    private var imageTexture: CVMetalTexture?
    
    private var metalDevice = MTLCreateSystemDefaultDevice()
    
    private let pixelFormat = MTLPixelFormat.rgba32Uint
    
    public weak var delegate: MetalBufferConverterDelegate?
    
    override init() {
        super.init()
        
        guard let metalDevice = metalDevice, CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, metalDevice, nil, &textureCache) == kCVReturnSuccess else {
            print("Unable to get Metal texture cache")
            return
        }
        
        cameraController.delegate = self
    }
    
    public func startCapturing(completion: @escaping (Bool) -> Void) {
        cameraController.start(completion: { completion($0) })
    }
    
    // MARK: - CameraCaptureControllerDelegate
    
    func cameraCaptureController(_ cameraCaptureController: CameraCaptureController, didRecieveSampleBuffer photoSampleBuffer: CMSampleBuffer?, withPreview previewSampleBuffer: CMSampleBuffer?, error: Error?) {
        
    }
    
    func cameraCaptureController(_ cameraCaptureController: CameraCaptureController, didReciveVideBuffer buffer: CMSampleBuffer?) {
        guard let buffer = buffer, let imageBuffer = CMSampleBufferGetImageBuffer(buffer) else {
            print("Unable to get imageBuffer from CMSampleBuffer")
            return
        }
        
        guard let textureCache = textureCache else {
            print("Texture cache is nil")
            return
        }
        
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        let planeIndex = 0
        let result = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, imageBuffer, nil, pixelFormat, width, height, planeIndex, &imageTexture)
        
        guard let unwrappedImageTexture = imageTexture, let texture = CVMetalTextureGetTexture(unwrappedImageTexture), result == kCVReturnSuccess else {
            print("Problem getting texted from imageTexture")
            return
        }
        
        delegate?.metalBufferConverter(self, didCreateTexture: texture)
        
    }
    
}
