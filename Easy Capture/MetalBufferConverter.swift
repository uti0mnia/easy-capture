//
//  MetalBufferConverter.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-10-30.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import AVFoundation
import Accelerate
import Metal

/*
 * This class is meant to handle the transformation of a CMSampleBuffer into a usable MTLTexture for metal.
 * For now it just simply transforms it, but later this will be use for handling different pixel types, and
 * different orientations.
 */
class MetalBufferConverter: NSObject {
    
    public enum MetalBufferConverterError: Swift.Error {
        case failedToGetTextureCache
        case failedToGetImageBuffer
        case failedToGetImageTexture
    }

    private var textureCache: CVMetalTextureCache?
    private var imageTexture: CVMetalTexture?
    
    private var metalDevice = MTLCreateSystemDefaultDevice()
    
    private let pixelFormat = MTLPixelFormat.rgba32Uint
    
    override init() {
        super.init()
        
        guard let metalDevice = metalDevice, CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, metalDevice, nil, &textureCache) == kCVReturnSuccess else {
            print("Unable to get Metal texture cache")
            return
        }
    }
    
    public func getTexture(sampleBuffer: CMSampleBuffer, planeIndex: Int = 0) throws -> MTLTexture {
        guard let textureCache = textureCache else {
            throw MetalBufferConverterError.failedToGetTextureCache
        }
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            throw MetalBufferConverterError.failedToGetImageBuffer
        }
        
        let isPlanar = CVPixelBufferIsPlanar(imageBuffer)
        let width = isPlanar ? CVPixelBufferGetWidthOfPlane(imageBuffer, planeIndex) : CVPixelBufferGetWidth(imageBuffer)
        let height = isPlanar ? CVPixelBufferGetHeightOfPlane(imageBuffer, planeIndex) : CVPixelBufferGetHeight(imageBuffer)
        
        var imageTexture: CVMetalTexture?
        
        let result = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, imageBuffer, nil, .bgra8Unorm, width, height, planeIndex, &imageTexture)
        
        guard let unwrappedImageTexture = imageTexture, let texture = CVMetalTextureGetTexture(unwrappedImageTexture), result == kCVReturnSuccess else {
            throw MetalBufferConverterError.failedToGetImageTexture
        }
        
        return texture
    }
    
}
