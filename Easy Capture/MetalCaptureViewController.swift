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
    
    private var device = MTLCreateSystemDefaultDevice()
    private var renderPipelineState: MTLRenderPipelineState?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMetalView()
        initRenderPipelineState()
    }
    
    override func loadView() {
        super.loadView()
        
        assert(device != nil, "Failed to create default Metal Device")
    }
    
    private func initMetalView() {
        metalView = MTKView(frame: self.view.bounds, device: device)
        metalView?.delegate = self
        metalView?.framebufferOnly = true
        metalView?.colorPixelFormat = .bgra8Unorm // TODO: test with bgra32Unorm?
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
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm // TODO: test with bgra32Unorm
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
        // nothing.
    }
    
    func draw(in view: MTKView) {
        guard let texture = texture, let device = device, let commandBuffer = device.makeCommandQueue()?.makeCommandBuffer() else {
            print("can't draw texture")
            return
        }
        render(texture, withCommandBuffer: commandBuffer, device: device)
    }
    
    private func render(_ texture: MTLTexture, withCommandBuffer commandBuffer: MTLCommandBuffer, device: MTLDevice) {
        guard let currentRenderPassDescriptor = metalView?.currentRenderPassDescriptor,
            let currentDrawable = metalView?.currentDrawable,
            let renderPipelineState = renderPipelineState,
            let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor) else {
//                semaphore.signal()
                return
        }
        
        encoder.pushDebugGroup("RenderFrame")
        encoder.setRenderPipelineState(renderPipelineState)
        encoder.setFragmentTexture(texture, index: 0)
        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: 1)
        encoder.popDebugGroup()
        encoder.endEncoding()
        
        // Called after the command buffer is scheduled
        commandBuffer.addScheduledHandler { [weak self] buffer in
            guard let strongSelf = self else {
                return
            }
            strongSelf.didRender(texture: texture)
//            strongSelf.semaphore.signal()
        }
        
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
    
    // MARK: - MetalCaptureSessionDelegate
    
//    func metalCameraController(_ metalCameraController: MetalCameraController, didReciveBufferAsTexture texture: MTLTexture) {
//        self.texture = texture
//    }
//
//    func metalCameraController(_ metalCameraController: MetalCameraController, didFinishRecordingVideoAtURL url: URL) {
//        PermissionManager.shared.photoPermission() { granted in
//            PHPhotoLibrary.shared().performChanges({
//                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url.absoluteURL)
//            }) { success, error in
//                if let error = error {
//                    print(error.localizedDescription)
//                } else {
//                    print("success!")
//                }
//            }
//        }
//    }
    
}








































