//
//  MTLTexture+UIImage.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-11-12.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import Metal
import MetalKit


extension MTLTexture {
    
    public func u0_bytes() -> UnsafeMutableRawPointer {
        let width = self.width
        let height = self.height
        let rowBytes = self.width * 4
        let p = malloc(width * height * 4)
        self.getBytes(p!, bytesPerRow: rowBytes, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)
        return p!
    }
    
    func u0_toImage() -> CGImage? {
        let p = self.u0_bytes()
        
        let pColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let rawBitmapInfo = CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: rawBitmapInfo)
        
        let selftureSize = self.width * self.height * 4
        let rowBytes = self.width * 4
        let provider = CGDataProvider(dataInfo: nil, data: p, size: selftureSize, releaseData: { _, _, _ in })
        let cgImageRef = CGImage(width: self.width, height: self.height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: rowBytes, space: pColorSpace, bitmapInfo: bitmapInfo, provider: provider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
        
        return cgImageRef
    }
}
