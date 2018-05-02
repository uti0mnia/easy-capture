//
//  MetalTextureConverter.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-11-15.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import MetalKit

class MetalTextureConverter: NSObject {
    
    public func convertToCGImage(_ texture: MTLTexture) -> CGImage? {
        // we can see what brga looks like from https://developer.apple.com/documentation/metal/fundamental_lessons/basic_texturing
        let rawBitmapInfo = CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        let bitmapInfo = CGBitmapInfo(rawValue: rawBitmapInfo)
        
        let bytesPerPixel = typicalMemorySize(for: texture)
        let textureSize = texture.width * texture.height * bytesPerPixel
        guard let data = getRawPointer(from: texture), let provider = CGDataProvider(dataInfo: nil, data: data, size: textureSize, releaseData: {_, _, _ in }) else {
            return nil
        }
        
        // bitsPerComponent - using .bgra8Unorm so there are 8 bits per component
        // bitsPerPixel - using .bgra8Unorm so it's 4 components times 8 bits for each pixel
        // space - using .brga8Unorm so obviously we'll use RGB
        // decode - no need to decode the image pixels
        // shouldInterpolate - no need since the image was taken on the device so the picture shouldn't be lower resolution than the device
        // intent - default is fine for this
        let image = CGImage(width: texture.width,
                            height: texture.height,
                            bitsPerComponent: 8,
                            bitsPerPixel: 4 * 8,
                            bytesPerRow: texture.width * bytesPerPixel,
                            space: CGColorSpaceCreateDeviceRGB(),
                            bitmapInfo: bitmapInfo,
                            provider: provider,
                            decode: nil,
                            shouldInterpolate: false,
                            intent: .defaultIntent)
        return image
    }
    
    // This will be useful in the future if I decide to support more types of colourspaces
    private func typicalMemorySize(for texture: MTLTexture) -> Int {
        switch texture.pixelFormat {
        case .r8Unorm, .r8Unorm_srgb, .r8Snorm, .r8Uint, .r8Sint:
            return 1 // bytes
        case .r16Unorm, .r16Snorm, .r16Uint, .r16Sint, .r16Float, .rg8Unorm, .rg8Unorm_srgb, .rg8Snorm, .rg8Uint, .rg8Sint:
            return 2 // bytes
        default:
            return 4 // bytes
        }
    }
    
    private func getRawPointer(from texture: MTLTexture) -> UnsafeMutableRawPointer? {
        let width = texture.width
        let height   = texture.height
        let rowBytes = texture.width * 4
        if let p = malloc(width * height * 4) {
            texture.getBytes(p, bytesPerRow: rowBytes, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)
            return p
        }
        
        return nil
    }
    
}
