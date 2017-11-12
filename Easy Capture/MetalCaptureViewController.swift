//
//  MetalRenderingViewController.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-10-30.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import MetalKit
import UIKit

class MetalCaptureViewController: UIViewController, MTKViewDelegate, MetalCaptureSessionDelegate {
    
    private var semaphore = DispatchSemaphore(value: 1)
    
    private var texture: MTLTexture?
    private var metalView: MTKView?
    
    private var device = MTLCreateSystemDefaultDevice()
    private var renderPipelineState: MTLRenderPipelineState?
    
    private(set) var metalCaptureSession = MetalCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMetalView()
        initRenderPipelineState()
        
        
        PermissionManager.shared.cameraPermission() { granted in
            guard granted else {
                print("no access to camera")
                return
            }
            
            self.metalCaptureSession.start() { success in
                guard success else {
                    return
                }
            }
            self.metalCaptureSession.delegate = self
        }
    }
    
    override func loadView() {
        super.loadView()
        
        assert(device != nil, "Failed to create default Metal Device")
    }
    
    private func initMetalView() {
        metalView = MTKView(frame: self.view.bounds, device: device)
        metalView?.delegate = self
        metalView?.framebufferOnly = true
        metalView?.colorPixelFormat = .bgra8Unorm
        metalView?.contentScaleFactor = UIScreen.main.scale
        metalView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(metalView!, at: 0)
    }
    
    private func initRenderPipelineState() {
        guard let device = device, let library = device.makeDefaultLibrary() else {
            return
        }
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.sampleCount = 1
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.depthAttachmentPixelFormat = .invalid
        
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "mapTexture")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "displayTexture")
        
        do {
            try renderPipelineState = device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        }
        catch {
            assertionFailure("Failed creating a render state pipeline. Can't render the texture without one.")
            return
        }
    }
    
    // MARK: - MTKViewDelegate
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // nothing.
    }
    
    func draw(in view: MTKView) {
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        autoreleasepool {
            guard let texture = texture, let device = device, let commandBuffer = device.makeCommandQueue()?.makeCommandBuffer() else {
                print("texture and/or device is nil, can't draw")
                semaphore.signal()
                return
            }
            
            render(texture, withCommandBuffer: commandBuffer, device: device)
        }
    }
    
    private func render(_ texture: MTLTexture, withCommandBuffer commandBuffer: MTLCommandBuffer, device: MTLDevice) {
        guard let currentRenderPassDescriptor = metalView?.currentRenderPassDescriptor,
            let currentDrawable = metalView?.currentDrawable,
            let renderPipelineState = renderPipelineState,
            let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor) else {
                semaphore.signal()
                return
        }
        
        encoder.pushDebugGroup("RenderFrame")
        encoder.setRenderPipelineState(renderPipelineState)
        encoder.setFragmentTexture(texture, index: 0)
        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: 1)
        encoder.popDebugGroup()
        encoder.endEncoding()
        
        // Called after the command buffer is scheduled
        commandBuffer.addScheduledHandler { [weak self] (buffer) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.semaphore.signal()
        }
        
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
    
    // MARK: - MetalCaptureSessionDelegate
    
    func metalCaptureSession(_ metalCaptureSession: MetalCaptureSession, didReciveBufferAsTexture texture: MTLTexture) {
        self.texture = texture
    }
}








































