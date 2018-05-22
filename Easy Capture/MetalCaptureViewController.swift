//
//  MetalRenderingViewController.swift
//  Easy Capture
//
//  Created by Casey McLewin on 2017-10-30.
//  Copyright © 2017 Casey McLewin. All rights reserved.
//

import AVFoundation
import MetalKit
import UIKit

class MetalCaptureViewController: UIViewController, MTKViewDelegate {
    
    private var semaphore = DispatchSemaphore(value: 1)
    
    public var texture: MTLTexture?
    private var metalView: MTKView?
    private var commandQueue: MTLCommandQueue?
    
    private let desiredAspectRatio: CGFloat = 1080.0/1920.0 // TODO: fix this if changing video ratio
    
    private var metalViewRect: CGRect {
        let height = max(view.bounds.height, view.bounds.width / desiredAspectRatio)
        let width = max(view.bounds.width, view.bounds.height * desiredAspectRatio)
        return CGRect.init(x: -(width - view.bounds.width) / 2, y: -(height - view.bounds.height) / 2, width: width, height: height)
    }
    
    private var device = MTLCreateSystemDefaultDevice()
    private var renderPipelineState: MTLRenderPipelineState?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMetalView()
        initMetalObjects()
    }
    
    override func loadView() {
        super.loadView()
        
        if device == nil {
            handleNoDevice()
        }
    }
    
    private func initMetalView() {
        metalView = MTKView(frame: metalViewRect, device: device)
        metalView?.delegate = self
        metalView?.framebufferOnly = true
        metalView?.colorPixelFormat = .bgra8Unorm // TODO: test with bgra32Unorm?
        metalView?.contentScaleFactor = UIScreen.main.scale
        metalView?.autoresizingMask  = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(metalView!, at: 0)
    }
    
    private func initMetalObjects() {
        guard let device = device, let library = device.makeDefaultLibrary() else {
            return
        }
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.sampleCount = 1
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm // TODO: test with bgra32Unorm
        pipelineDescriptor.depthAttachmentPixelFormat = .invalid
        
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "mapTexture")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "displayTexture")
        
        do {
            try renderPipelineState = device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        }
        catch {
            handleNoRenderPipelineDescriptor()
            return
        }
        
        commandQueue = device.makeCommandQueue()
    }
    
    public func handleNoDevice() {
        // For sublcassing.
    }
    
    public func handleNoRenderPipelineDescriptor() {
        
    }
    
    public func displayError(message: String?) {
        guard self.isViewLoaded, view.window != nil else {
            return
        }
        
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        
        present(alert, animated: true, completion: nil)
    }
    
    public func didRender(texture: MTLTexture) {
        // for subclasses
    }
    
    // MARK: - MTKViewDelegate
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Do nothing.
    }
    
    func draw(in view: MTKView) {
        let result = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        autoreleasepool {
            guard result == .success, let texture = texture, let device = device, let commandBuffer = commandQueue?.makeCommandBuffer() else {
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
        commandBuffer.addScheduledHandler { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.didRender(texture: texture)
            strongSelf.semaphore.signal()
        }
        
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
    
}








































